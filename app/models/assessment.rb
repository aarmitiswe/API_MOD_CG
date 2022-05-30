class Assessment < ActiveRecord::Base
  include SendInvitation

  ASSESSOR_TYPE = 'assessor'
  ENGLISH_TYPE = 'english'
  PERSONALITY_TYPE = 'personality'
  QEC_TYPE = 'qec'


  belongs_to :job_application_status_change

  has_attached_file :document_report, dependent: :destroy

  validates_attachment_content_type :document_report, content_type: [
      "application/pdf", "application/msword", "application/vnd.ms-office", "text/plain", "application/xls",
      "application/xlsx", "application/doc", "application/docx", "application/ppt", "application/pptx",
      "image/jpg", "image/jpeg", "image/png", "image/gif", "image/bmp",
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
  ]

  after_create :send_mails
  after_save :send_mails_change_status, on: :update
  before_save :set_extension

  def set_extension
    documents = ["document_report"]

    documents.each do |document_field|
      next if self.send(document_field).blank?
      tempfile = self.send(document_field).queued_for_write[:original]
      unless tempfile.nil?
        extension = File.extname(tempfile.original_filename)
        if !extension || extension == ''
          mime = tempfile.content_type
          ext = Rack::Mime::MIME_TYPES.invert[mime]
          # Rails.application.debugger "#{tempfile.original_filename}#{ext}"
          self.send(document_field).instance_write :file_name, "#{tempfile.original_filename}#{ext}"
        end
      end
    end

    true
  end

  def job
    self.job_application_status_change.job
  end

  def jobseeker
    self.job_application_status_change.jobseeker.try(:jobseeker)
  end

  def send_mails
    return if self.jobseeker.employment_type == "external"
    template_values = self.job_application_status_change.job_application.get_feedback_template_values

    template_values[:QEAAssessor] = User.qec_coordinator.first.try(:full_name) || "NA"

    creator = self.job_application_status_change.employer
    template_values[:RecruiterName] = creator.try(:full_name) || "NA"

    receivers = [{email: creator.email, name: creator.full_name}] | User.qec_coordinator.map{|u| {email: u.email, name: u.full_name}}

    self.send_email "create_assessment",
                    receivers,
                    {
                        message_body: nil,
                        message_subject: "مركز تقييم الكفاءات - تقييم وظيفي للمرشح",
                        template_values: template_values
                    }
  end

  def send_mails_change_status
    if !self.status.nil? && self.status != 'not_applicable'
      template_values = self.job_application_status_change.job_application.get_feedback_template_values

      template_values[:QEAAssessor] = User.qec_coordinator.first.try(:full_name) || "NA"

      creator = self.job_application_status_change.employer
      template_values[:RecruiterName] = creator.try(:full_name) || "NA"
      receivers = User.qec_coordinator.map{|u| {email: u.email, name: u.full_name}} | [{email: creator.email, name: creator.full_name}] | User.recruiters_for_job(self.job).map{|u| {email: u.email, name: u.full_name}}

      self.send_email "result_assessment",
                      receivers,
                      {
                          message_body: nil,
                          message_subject: "نتيجة التقييم في مركز تقييم الكفاءات للمرشح",
                          template_values: template_values
                      }

    end
  end

end
