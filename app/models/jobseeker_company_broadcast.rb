require 'open-uri'
require 'base64'
require 'net/http'
require 'tilt/erb'


class JobseekerCompanyBroadcast < ActiveRecord::Base
  include SendInvitation

  belongs_to :jobseeker
  belongs_to :company

  validate :check_remaining_credits

  before_create :send_resume_to_company

  scope :success, -> { where(status: 'success') }
  scope :fail, -> { where(status: 'fail') }

  def check_remaining_credits
    unless self.jobseeker.has_enough_credit?
      self.errors.add(:base, "No Enough Credits")
    end
  end

  def self.create_bulk company_ids, jobseeker, allow_duplicate
    if company_ids.size <= jobseeker.num_remaining_credits
      if allow_duplicate
        jobseeker_company_broadcasts = JobseekerCompanyBroadcast.create(company_ids.map{|company_id| {company_id: company_id, jobseeker_id: jobseeker.id}})
        JobseekerCompanyBroadcast.send_remaining_credits jobseeker
        # company_ids.each do |company_id|
        #   JobseekerCompanyBroadcast.create(company_id: company_id, jobseeker_id: jobseeker.id)
        # end
        return jobseeker_company_broadcasts
      else
        if (jobseeker.broadcasted_companies.pluck(:id) & company_ids).blank?
          jobseeker_company_broadcasts = JobseekerCompanyBroadcast.create(company_ids.map{|company_id| {company_id: company_id, jobseeker_id: jobseeker.id}})
          JobseekerCompanyBroadcast.send_remaining_credits jobseeker
          return jobseeker_company_broadcasts
        else
          return 'has_duplicate'
        end
      end
    else
      return 'no_credits'
    end
  end

  def self.send_remaining_credits jobseeker
    recipients = [ {email: jobseeker.user.email, name: jobseeker.full_name} ]

    template = Tilt::ERBTemplate.new("#{Rails.root.to_s}/app/views/api/v1/jobseeker_company_broadcasts/remaining_jobseeker_credits.html.erb")
    output = template.render(jobseeker, jobseeker: jobseeker)



    response_mandrill = jobseeker.user.send_email("Remaining Credits", recipients, {
        message_subject: "Profile Broadcast | Credit Balance",
        message_body: output
    })

    response_mandrill
  end

  def send_resume_to_company
    #   Send jobseeker profile to the company
    vars = [
        {name: "jobseeker_name", content: self.jobseeker.full_name},
        {name: "avatar", content: self.jobseeker.user.avatar.url},
        {name: "current_position", content: self.jobseeker.current_position},
        {name: "current_company", content: self.jobseeker.current_company.try(:company).try(:name) || 'N/A'},
        {name: "sector", content: self.jobseeker.sector.try(:name)},
        {name: "visa_status", content: self.jobseeker.visa_status.try(:name)},
        {name: "functional_area", content: self.jobseeker.functional_area.try(:area)},
        {name: "years_of_experience", content: self.jobseeker.years_of_experience},
        {name: "job_education", content: self.jobseeker.job_education.try(:level) || 'N/A'},
        {name: "skills", content: self.jobseeker.skills.pluck(:name).join(",")},
        {name: "jobseeker_email", content: self.jobseeker.user.email},
        {name: "jobseeker_phone", content: self.jobseeker.mobile_phone},
        {name: "owner_name", content: self.company.owner.full_name},
        {name: "company_name", content: self.company.name},
        {name: "website", content: Rails.application.secrets["FRONTEND"]},
        {name: "user_id", content: self.jobseeker.user.id},
        {name: "nationality", content: self.jobseeker.nationality.try(:name) || 'N/A'},
        {name: "city", content: self.jobseeker.user.city.try(:name) || 'N/A'},
        {name: "country", content: self.jobseeker.user.country.try(:name) || 'N/A'}
    ]

    recipients = [ {email: self.company.owner.email, name: self.company.owner.full_name} ]

    default_resume = self.jobseeker.jobseeker_resumes.default.first || self.jobseeker.jobseeker_resumes.last

    # resume_document_content = open(default_resume.document.url) do |io|
    #   io.set_encoding(Encoding.default_external)
    #   io.read
    # end

    attachments = []
    # open("http://www.your-website.net", http_basic_authentication: ["user", "password"])

    if default_resume
      resume_document_content = Base64.encode64(open(default_resume.document.url) { |io| io.read })

      attachments = [{
                         content: resume_document_content,
                         name: default_resume.document_file_name,
                         type: default_resume.document_content_type
                     }]
    else
    #   Save As PDF
    #   http://local.bloovo.com:3001/api/jobseekers/41976/display_profile_pdf
    #   url = "#{Rails.application.secrets["BACKEND"]}/api/jobseekers/#{self.jobseeker.user.id}/display_profile_pdf"
    #   url = URI.parse("#{Rails.application.secrets["BACKEND"]}/api/jobseekers/#{self.jobseeker.user.id}/display_profile_pdf")
    #
    #   request = Net::HTTP::Get.new(url.to_s, {'Authorization' => self.jobseeker.user.auth_token})
    #
    #   response = Net::HTTP.start(url.host, url.port) {|http|
    #     http.request(request)
    #   }

      # resume_document_content = Base64.encode64(open("#{Rails.application.secrets["BACKEND"]}/api/jobseekers/#{self.jobseeker.user.id}/display_profile_pdf"))
      # resume_document_content = Base64.encode64(response.body)
      resume_document_content = Base64.encode64(self.jobseeker.get_profile_as_pdf)

      attachments = [{
                         content: resume_document_content,
                         name: "#{self.jobseeker.full_name}-Resume.pdf",
                         type: "application/pdf"
                     }]
    end

    template = Tilt::ERBTemplate.new("#{Rails.root.to_s}/app/views/api/v1/jobseeker_company_broadcasts/broadcast_jobseeker_profile.html.erb")

    output = template.render(self.jobseeker, jobseeker: self.jobseeker, company: self.company)

    response_mandrill = jobseeker.user.send_email("Broadcast Profile", recipients, {
        message_subject: "#{self.jobseeker.full_name} has Broadcasted his Profile to you Showing an Interest to Join your Company",
        message_body: output,
        attachments: attachments
    })


    # [{"email"=>"myakout@bloovo.com", "status"=>"sent", "_id"=>"3725b5e9d23f41ca9543688b5ddfba47", "reject_reason"=>nil}]
    # response_mandrill = self.send_email_template "broadcast_jobseeker_profile_to_employer", vars, recipients, email_from, "BLOOVO.COM | Send Prodcast Company", attachments

    if response_mandrill.first["status"] == 'rejected' || response_mandrill.first["status"] == 'invalid'
      self.status = 'fail'
    else
      self.status = 'success'
    end

    response_mandrill
  end
end
