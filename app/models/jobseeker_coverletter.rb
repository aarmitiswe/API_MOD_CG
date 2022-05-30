class JobseekerCoverletter < ActiveRecord::Base
  include DocumentUpload

  belongs_to :jobseeker
  has_many :job_applications, dependent: :destroy

  after_save :check_default

  after_initialize :set_deleted_flag

  # validates_presence_of :jobseeker_id
  # TODO: Remove the comment after deploy to production & stable DB
  # validates_attachment_presence :document

  scope :active, -> { where.not(is_deleted: true) }

  UploadDocument = Struct.new(:jobseeker_coverletter, :document_local_path) do
    def perform
      jobseeker_coverletter.document = File.open(document_local_path)
      jobseeker_coverletter.save
    end
  end

  protected
    def check_default
      if self.default == true && self.jobseeker
        self.jobseeker.jobseeker_coverletters.where(default: true).where.not(id: self.id).update_all(default: false)
      end
    end

    def set_deleted_flag
      self.is_deleted = false
    end
end
