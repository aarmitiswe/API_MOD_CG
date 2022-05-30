class Position < ActiveRecord::Base
  self.per_page = 10
  belongs_to :job_type
  belongs_to :grade
  belongs_to :job_status
  belongs_to :position_status
  belongs_to :position_cv_source
  belongs_to :organization
  belongs_to :job_experience_level

  has_many :jobs, dependent: :destroy

  scope :has_not_jobs, -> { where.not(id: Job.not_rejected.pluck(:position_id)) }
  scope :has_not_jobs_or_rejected_jobs, -> { where.not(id: Job.not_rejected.pluck(:position_id)) }
  scope :internal, -> { where(employment_type: 'internal') }
  scope :external, -> { where(employment_type: 'external') }
  scope :both, -> { where(employment_type: 'both') }
  scope :active, -> { where(is_deleted: false ) }
  scope :is_deleted, -> { where(is_deleted: true ) }
  # scope :has_not_jobs, -> (user) { where.not(id: user.jobs.pluck(:position_id)) }
  #
  scope :assessor_positions, -> { where(grade_id: Grade.assessor_grades.pluck(:id)) }

  validates_presence_of :oracle_id, :organization_id, :job_title

  def ar_employment_type
    hash = Job::EMPLOYMENT_TYPE_MAIL

    hash[self.employment_type]
  end

  def lock_position
    url = "#{Rails.application.secrets[:ORACLE_URL]}webservices/rest/UPD_POS_STATUS/xx_mod_update_pos_status/"
    uri = URI.parse(url)
    request_body = {
      "P_POSITION_ID" => self.oracle_id,
      "P_RESERVATION_START_DATE" => Date.today.strftime("%d/%m/%Y"),
      "P_RESERVED_STATUS" => "NEW_HIRE"
    }

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = false
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(uri)
    request.basic_auth(Rails.application.secrets[:ORACLE_USERNAME], Rails.application.secrets[:ORACLE_PASSWORD])
    request["Content-Type"] = 'application/json'
    request.body = request_body.to_json
    puts "BODY: "
    puts request.body
    response = http.request(request)
    puts "RESPONSE: "
    puts response
    res_body = JSON.parse(response.body)
    puts "JSON RESPONSE: "
    puts res_body


    open_mode = "a+"
    File.open("#{Rails.root}/log/xx_mod_update_pos_status_lock#{Date.today}.txt", open_mode) do |f|
      f.write("+++++++++++++++++++++++++++++++++++++++++++++++++++++++")
      f.write("\n")
      f.write(url)
      f.write("\n")
      f.write(request.body)
      f.write("\n")
      f.write(res_body)
      f.write("\n")
      f.write("+++++++++++++++++++++++++++++++++++++++++++++++++++++++")
      f.write("\n")

      f.close
    end

    if res_body.present? && res_body["OutputParameters"].present? && res_body["OutputParameters"]["O_STATUS_MESSAGE"] == "SUCCESS"
      lock_code = res_body["OutputParameters"]["O_POSITION_EXTRA_INFO_ID"].to_i
      self.update(lock_code: lock_code)
    end

  end

  def unlock_position

    return if self.lock_code.blank?

    url = "#{Rails.application.secrets[:ORACLE_URL]}webservices/rest/UPD_POS_STATUS/xx_mod_update_pos_status/"
    uri = URI.parse(url)
    request_body = {
      "P_POSITION_ID" => self.oracle_id,
      "P_POSITION_EXTRA_INFO_ID" => self.lock_code,
      "P_RESERVED_STATUS" => "NEW_HIRE",
      "P_RESERVATION_END_DATE" => Date.today.strftime("%d/%m/%Y")
    }
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = false
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(uri)
    request.basic_auth(Rails.application.secrets[:ORACLE_USERNAME], Rails.application.secrets[:ORACLE_PASSWORD])
    request["Content-Type"] = 'application/json'
    request.body = request_body.to_json
    puts "BODY: "
    puts request.body
    response = http.request(request)
    puts "RESPONSE: "
    puts response
    res_body = JSON.parse(response.body)
    puts "JSON RESPONSE: "
    puts res_body

    open_mode = "a+"
    File.open("#{Rails.root}/log/xx_mod_update_pos_status_unlock#{Date.today}.txt", open_mode) do |f|
      f.write("+++++++++++++++++++++++++++++++++++++++++++++++++++++++")
      f.write("\n")
      f.write(url)
      f.write("\n")
      f.write(request.body)
      f.write("\n")
      f.write(res_body)
      f.write("\n")
      f.write("+++++++++++++++++++++++++++++++++++++++++++++++++++++++")
      f.write("\n")

      f.close
    end

    if res_body.present? && res_body["OutputParameters"].present? && res_body["OutputParameters"]["O_STATUS_MESSAGE"] == "SUCCESS"
      lock_code = res_body["OutputParameters"]["O_POSITION_EXTRA_INFO_ID"].to_i
      self.update(lock_code: nil)
    end
  end




end