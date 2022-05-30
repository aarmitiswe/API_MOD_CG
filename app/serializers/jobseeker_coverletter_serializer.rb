class JobseekerCoverletterSerializer < ActiveModel::Serializer
  attributes :id, :file_path, :title, :default, :description, :document, :document_file_name, :default
end
