class NoteSerializer < ActiveModel::Serializer
  attributes :id, :note, :author_name, :created_at
end
