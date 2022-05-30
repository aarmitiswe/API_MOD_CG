class BoardingForm < ActiveRecord::Base
  include SendInvitation

  belongs_to :job_application

  has_many :boarding_requisitions, dependent: :destroy



  has_attached_file :signed_joining_document, dependent: :destroy

  validates_attachment_content_type :signed_joining_document, content_type: [
      "application/pdf", "application/msword", "application/vnd.ms-office", "text/plain", "application/xls",
      "application/xlsx", "application/doc", "application/docx", "application/ppt", "application/pptx",
      "image/jpg", "image/jpeg", "image/png", "image/gif", "image/bmp",
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
  ]

  has_attached_file :signed_stc_document, dependent: :destroy

  validates_attachment_content_type :signed_stc_document, content_type: [
      "application/pdf", "application/msword", "application/vnd.ms-office", "text/plain", "application/xls",
      "application/xlsx", "application/doc", "application/docx", "application/ppt", "application/pptx",
      "image/jpg", "image/jpeg", "image/png", "image/gif", "image/bmp",
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
  ]

  after_create :create_boarding_requisitions
  after_create :send_request_to_onboarding_manager
  # after_save :send_request_to_recruitment_manager
  after_save :move_to_complete
  before_save :set_extension

  def job_application_status_change
    self.job_application.job_application_status_changes.last
  end

  def send_request_to_onboarding_manager
    template_values = self.job_application_status_change.get_feedback_template_values

    self.send_email "ask_approve_onboarding_manager",
                          [{email: User.onboarding_manager.first.email, name: User.onboarding_manager.first.full_name}],
                          {
                              message_body: nil,
                              message_subject: " اعتماد نموذج المباشرة للموظف ",
                              template_values: template_values
                          }
  end

  def send_request_to_recruitment_manager
    # return if self.signed_joining_document_file_name.nil? || self.signed_stc_document_file_name.nil? || self.boarding_requisitions.approved.blank?
    return if self.boarding_requisitions.approved.count != 1
    template_values = self.job_application_status_change.get_feedback_template_values
    template_values[:JoiningDate] = self.expected_joining_date

    self.send_email "notify_approve_joining_form_recruitment_manager",
                          [{email: User.recruitment_manager.first.email, name: User.recruitment_manager.first.full_name}],
                          {
                              message_body: nil,
                              message_subject: " اعتماد نموذج المباشرة للموظف ",
                              template_values: template_values
                          }

  end

  def set_extension
    documents = ["signed_joining_document", "signed_stc_document"]

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

  def move_to_complete
    if self.support_management_checked_at &&
        self.it_management_checked_at &&
        self.business_service_management_checked_at &&
        self.security_management_checked_at
      JobApplicationStatusChange.create(job_application_id: self.job_application_status_change.job_application_id,
                                        job_application_status_id: JobApplicationStatus.find_by_status('Completed').try(:id),
                                        employer_id: self.job_application_status_change.employer_id, jobseeker_id: self.job_application_status_change.jobseeker_id)
    end
  end

  def create_boarding_requisitions
    User.onboarding_manager.each do |user|
      BoardingRequisition.create(user_id: user.id, job_application_id: self.job_application_id, boarding_form_id: self.id, status: 'sent')
    end
  end
end
