class JobseekerCertificateSerializer < ActiveModel::Serializer
  include DateHelper
  attributes :id, :name, :institute , :attachment, :grade,
             :university_name, :start_date, :end_date, :duration, :grade, :document, :document_file_name

  def university_name
    object.institute
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
