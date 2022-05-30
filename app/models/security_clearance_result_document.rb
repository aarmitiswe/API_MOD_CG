require 'yomu'

class SecurityClearanceResultDocument < ActiveRecord::Base
  include DocumentUpload

  belongs_to :job_application
  #has_many :job_applications, dependent: :destroy

  #after_save :check_default
  #after_initialize :set_deleted_flag
  before_save :set_default_name

  #scope :active, -> { where.not(is_deleted: true) }
  scope :default, -> { where(default: true) }

  # validates_presence_of :jobseeker_id
  # TODO: Remove the comment after deploy to production & stable DB
  # validates_attachment_presence :document

  UploadDocument = Struct.new(:security_clearance_result_document, :document_local_path) do
    def perform
      security_clearance_result_document.document = File.open(document_local_path)
      security_clearance_result_document.save
    end
  end

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

  protected
    def check_default
      if self.default == true && self.job_application
        self.job_application.security_clearance_result_document.where(default: true).where.not(id: self.id).update_all(default: false)
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


