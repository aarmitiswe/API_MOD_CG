class JobseekerEducationSerializer < ActiveModel::Serializer
  include DateHelper
  attributes :id, :school, :grade, :field_of_study,
             :name, :start_date, :end_date, :duration,
             :document_file_name, :document, :degree_type, :max_grade

  has_one :city
  has_one :country
  has_one :job_education
  has_one :university

  def name
    object.school
  end

  def education_qualification
    object.field_of_study
  end

  def start_date
    object.from
  end

  def end_date
    object.to
  end

  def duration
    subtract_to_years_months(object.from, object.to)
  end
end
