class JobseekerOnBoardDocumentSerializer < ActiveModel::Serializer
  attributes :id, :document, :type_of_document, :document_url

  def document_url
    object.document(:origin)
  end
  
end
