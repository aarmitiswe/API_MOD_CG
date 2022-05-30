class JobseekerEducation < ActiveRecord::Base
  include DocumentUpload

  belongs_to :jobseeker
  belongs_to :job_education
  belongs_to :university
  belongs_to :city, foreign_key: 'city_id'
  belongs_to :country, foreign_key: 'country_id'

  # validates_presence_of :school, :jobseeker_id
  validates_presence_of :school
  after_save :set_jobseeker_graduate_program
  after_destroy :set_jobseeker_graduate_program

  UploadDocument = Struct.new(:jobseeker_education, :document_local_path) do
    def perform
      jobseeker_education.document = File.open(document_local_path)
      jobseeker_education.save
    end
  end


  def set_jobseeker_graduate_program
    self.jobseeker.jobseeker_graduate_program.update(nationality_id: self.jobseeker.nationality_id, age: self.jobseeker.age,
                                           bachelor_gpa: self.jobseeker.highest_bachelor_gpa,
                                           master_gpa: self.jobseeker.highest_master_gpa) if self.jobseeker.jobseeker_graduate_program
  end
end
