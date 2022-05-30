class JobseekerGraduateProgramSerializer < ActiveModel::Serializer
  attributes :id, :ielts_score, :ielts_document, :toefl_score, :toefl_document, :age, :bachelor_gpa, :master_gpa,
             :is_matched_criteria

  def is_matched_criteria
    object.is_matched_criteria?
  end
end