class FolderDetailsSerializer < FolderSerializer
  attributes :ancestors

  has_many :jobseeker_folders

  def ancestors
    object.ancestors.map { |obj| {id: obj.id, name: obj.name} }.reverse
  end
end