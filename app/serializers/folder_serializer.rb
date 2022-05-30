class FolderSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :level, :parent_id, :has_more
  has_many :sub_folders
  has_many :assigned_user_ids

  def sub_folders
    object.top_five_sub_folders
  end

  def has_more
    object.sub_folders.count > Folder::LIMIT_SUB_FOLDERS
  end
end
