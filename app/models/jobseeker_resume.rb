require 'yomu'

class JobseekerResume < ActiveRecord::Base
  include DocumentUpload

  belongs_to :jobseeker
  has_many :job_applications, dependent: :destroy

  after_save :check_default
  after_initialize :set_deleted_flag
  # before_save :set_default_name
  # after_save :set_resume_data

  scope :active, -> { where.not(is_deleted: true) }
  scope :default, -> { where(default: true) }

  # validates_presence_of :jobseeker_id
  # TODO: Remove the comment after deploy to production & stable DB
  # validates_attachment_presence :document

  UploadDocument = Struct.new(:jobseeker_resume, :document_local_path) do
    def perform
      jobseeker_resume.document = File.open(document_local_path)
      jobseeker_resume.save
    end
  end

  def self.update_resume_data
    self.where(resume_data: nil).order('id DESC').each do |jobseeker_resume|
      jobseeker_resume.set_resume_data 
    end

  end

  def set_resume_data
    unless self.document.path.blank?
      yomu = Yomu.new self.document.path
      self.update_column(:resume_data, yomu.text.delete("\?\"\.\:").squish) if yomu.text.present?
    else
      p "document url is not exist on s3 bucket"
    end
  end

  protected
    def check_default
      if self.default == true && self.jobseeker
        self.jobseeker.jobseeker_resumes.where(default: true).where.not(id: self.id).update_all(default: false)
      end
    end

    def set_deleted_flag
      self.is_deleted = false
    end

    # def set_default_name
    #   self.file_path = "#{self.jobseeker.id}'s CV #{self.jobseeker.jobseeker_resumes.count + 1}"
    #   self.document_file_name = "#{self.jobseeker.id}'s CV #{self.jobseeker.jobseeker_resumes.count + 1}"
    # end


end
