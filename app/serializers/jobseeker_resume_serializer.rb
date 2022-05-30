class JobseekerResumeSerializer < ActiveModel::Serializer
  attributes :id, :title, :document, :document_file_name, :default, :file_path, :resume_data
end
