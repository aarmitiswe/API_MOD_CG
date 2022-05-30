class JobseekerRequiredDocumentSerializer < ActiveModel::Serializer
    attributes :id, :document_type, :document, :status, :employer_comment
    has_one :job_application_status_change
end