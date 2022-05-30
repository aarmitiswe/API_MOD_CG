class AssessmentSerializer < ActiveModel::Serializer
  attributes :id, :assessment_type, :status, :comment, :document_report
end
