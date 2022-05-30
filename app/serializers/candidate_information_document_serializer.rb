class CandidateInformationDocumentSerializer < ActiveModel::Serializer
  delegate :current_user, to: :scope

  attributes :id, :name, :id_number, :job_title, :job_grade, :agency_id, :status,
             :current_employer, :document, :document_two, :document_three, :document_four, :document_report, :updated_at,
             :document_passport, :document_national_address, :document_edu_cert, :document_training_cert

  has_one :user

  def document
    object.document
  end

  def document_two
    object.document_two
  end

  def document_three
    object.document_three
  end

  def document_four
    object.document_four
  end

  def document_report
    object.document_report
  end

  def document_passport
    object.document_passport
  end

  def document_national_address
    object.document_national_address
  end

  def document_edu_cert
    object.document_edu_cert
  end

  def document_training_cert
    object.document_training_cert
  end

end

