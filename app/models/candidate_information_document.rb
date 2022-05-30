require 'yomu'

class CandidateInformationDocument < ActiveRecord::Base
  include SendInvitation

  APPROVE_STATUS = 'approved'
  REJECT_STATUS = 'rejected'

  has_attached_file :document, dependent: :destroy

  validates_attachment_content_type :document, content_type: [
    "application/pdf", "application/msword", "application/vnd.ms-office", "text/plain", "application/xls",
    "application/xlsx", "application/doc", "application/docx", "application/ppt", "application/pptx",
    "image/jpg", "image/jpeg", "image/png", "image/gif", "image/bmp",
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
  ]

  has_attached_file :document_two, dependent: :destroy

  validates_attachment_content_type :document_two, content_type: [
      "application/pdf", "application/msword", "application/vnd.ms-office", "text/plain", "application/xls",
      "application/xlsx", "application/doc", "application/docx", "application/ppt", "application/pptx",
      "image/jpg", "image/jpeg", "image/png", "image/gif", "image/bmp",
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
  ]

  has_attached_file :document_three, dependent: :destroy

  validates_attachment_content_type :document_three, content_type: [
      "application/pdf", "application/msword", "application/vnd.ms-office", "text/plain", "application/xls",
      "application/xlsx", "application/doc", "application/docx", "application/ppt", "application/pptx",
      "image/jpg", "image/jpeg", "image/png", "image/gif", "image/bmp",
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
  ]

  has_attached_file :document_four, dependent: :destroy

  validates_attachment_content_type :document_four, content_type: [
      "application/pdf", "application/msword", "application/vnd.ms-office", "text/plain", "application/xls",
      "application/xlsx", "application/doc", "application/docx", "application/ppt", "application/pptx",
      "image/jpg", "image/jpeg", "image/png", "image/gif", "image/bmp",
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
  ]

  has_attached_file :document_report, dependent: :destroy

  validates_attachment_content_type :document_report, content_type: [
      "application/pdf", "application/msword", "application/vnd.ms-office", "text/plain", "application/xls",
      "application/xlsx", "application/doc", "application/docx", "application/ppt", "application/pptx",
      "image/jpg", "image/jpeg", "image/png", "image/gif", "image/bmp",
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
  ]

  has_attached_file :document_passport, dependent: :destroy

  validates_attachment_content_type :document_passport, content_type: [
      "application/pdf", "application/msword", "application/vnd.ms-office", "text/plain", "application/xls",
      "application/xlsx", "application/doc", "application/docx", "application/ppt", "application/pptx",
      "image/jpg", "image/jpeg", "image/png", "image/gif", "image/bmp",
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
  ]


  has_attached_file :document_edu_cert, dependent: :destroy

  validates_attachment_content_type :document_edu_cert, content_type: [
      "application/pdf", "application/msword", "application/vnd.ms-office", "text/plain", "application/xls",
      "application/xlsx", "application/doc", "application/docx", "application/ppt", "application/pptx",
      "image/jpg", "image/jpeg", "image/png", "image/gif", "image/bmp",
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
  ]

  has_attached_file :document_national_address, dependent: :destroy

  validates_attachment_content_type :document_national_address, content_type: [
      "application/pdf", "application/msword", "application/vnd.ms-office", "text/plain", "application/xls",
      "application/xlsx", "application/doc", "application/docx", "application/ppt", "application/pptx",
      "image/jpg", "image/jpeg", "image/png", "image/gif", "image/bmp",
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
  ]

  has_attached_file :document_training_cert, dependent: :destroy

  validates_attachment_content_type :document_training_cert, content_type: [
      "application/pdf", "application/msword", "application/vnd.ms-office", "text/plain", "application/xls",
      "application/xlsx", "application/doc", "application/docx", "application/ppt", "application/pptx",
      "image/jpg", "image/jpeg", "image/png", "image/gif", "image/bmp",
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
  ]


  belongs_to :job_application
  #has_many :job_applications, dependent: :destroy
  belongs_to :job_application_status_change
  belongs_to :user
  #after_save :check_default
  #after_initialize :set_deleted_flag
  # before_save :set_default_name
  after_save :check_and_send_notification
  after_update :move_to_assessment

  before_save :before_save_doc


  #scope :active, -> { where.not(is_deleted: true) }
  scope :default, -> { where(default: true) }
  scope :approved, -> { where(status: APPROVE_STATUS) }
  scope :rejected, -> { where(status: REJECT_STATUS) }

  def jobseeker
    self.job_application.jobseeker
  end

  def job
    self.job_application.job
  end

  def before_save_doc
    documents = ["document", "document_two", "document_three", "document_four", "document_report",
                 "document_passport", "document_edu_cert", "document_national_address", "document_training_cert"]

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

  # validates_presence_of :jobseeker_id
  # TODO: Remove the comment after deploy to production & stable DB
  # validates_attachment_presence :document

  # UploadDocument = Struct.new(:candidate_information_document, :document_local_path) do
  #   def perform
  #     candidate_information_document.document = File.open(document_local_path)
  #     candidate_information_document.save
  #   end
  # end

=begin
  def self.update_resume_data
    self.where(resume_data: nil).order('id DESC').each do |jobseeker_resume|
      jobseeker_resume.set_resume_data
    end

  end

  def set_resume_data
    unless self.document.url.blank?
      yomu = Yomu.new self.document.url
      self.update_column(:resume_data, yomu.text)
    else
      p "document url is not exist on s3 bucket"
    end
  end
=end

  #Move JobApplication To Assessment After Security
  def move_to_assessment
    self.job_application.update(job_application_status_id: JobApplicationStatus.find_by_status('Assessment').id) if !self.status.blank?
  end

  def check_and_send_notification
    template_values = self.job_application.get_feedback_template_values

    if !self.status.blank?
      User.recruiters_for_job(self.job).each_with_index do |rec, index|
        template_values[:RecruiterName] = rec.full_name
        template_values[:SecurityClearanceOfficerName] = rec.full_name

        receivers = [{email: rec.email, name: rec.full_name}, {email: self.job.user.email, name: self.job.user.full_name}] | User.recruitment_manager.map{|u| {email: u.email, name: u.full_name}}

        self.send_email "complete_security_clearance",
                        receivers,
                        {
                            message_body: nil,
                            message_subject: "اكتمال التزكيه الأمنية للمرشح #{self.jobseeker.full_name} رقم الطلب #{self.job.id}",
                            template_values: template_values
                        }

        if self.status == REJECT_STATUS
          self.send_email "reject_security_clearance",
                          receivers,
                          {
                              message_body: nil,
                              message_subject: "رفض التزكيه الأمنية للمرشح #{self.jobseeker.full_name} رقم الطلب #{self.job.id}",
                              template_values: template_values
                          }
        end
      end
    end


  end

  protected
    def check_default
      if self.default == true && self.job_application
        self.job_application.candidate_information_documents.where(default: true).where.not(id: self.id).update_all(default: false)
      end
    end

=begin
    def set_deleted_flag
      self.is_deleted = false
    end
=end

    def set_default_name
      self.file_path = "Job Application #{self.job_application.id} Candidate Infomation Document"
      self.document_file_name = "Job Application #{self.job_application.id} Candidate Infomation Document"
    end
end
