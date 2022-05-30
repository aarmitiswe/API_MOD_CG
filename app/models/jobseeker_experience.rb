class JobseekerExperience < ActiveRecord::Base
  include DocumentUpload

  belongs_to :jobseeker, inverse_of: :jobseeker_experiences
  has_one :user, through: :jobseeker
  belongs_to :sector
  belongs_to :city, foreign_key: 'city_id'
  belongs_to :country, foreign_key: 'country_id'
  belongs_to :company, foreign_key: 'company_id'

  validates_presence_of :country_id, :city_id, :company_name, :position


  # validates_presence_of :position, :company_name, :jobseeker_id

  before_save :load_company_name

  def company_obj
    Company.find_by_name(self.company)
  end

  UploadDocument = Struct.new(:jobseeker_experience, :document_local_path) do
    def perform
      jobseeker_experience.document = File.open(document_local_path)
      jobseeker_experience.save
    end
  end

  # this for experience content
  ransacker :content, formatter: proc { |v| v.mb_chars.downcase.to_s } do |parent|
    Arel::Nodes::NamedFunction.new('LOWER',
                                   [Arel::Nodes::NamedFunction.new('concat_ws',
                                                                   [Arel::Nodes.build_quoted(' '), parent.table[:position], parent.table[:company_name], parent.table[:description]])])
  end

  private
    def load_company_name
      self.company_name = self.company.name if self.company
    end
end
