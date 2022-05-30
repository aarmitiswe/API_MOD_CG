class BranchSerializer < ActiveModel::Serializer
  attributes :id, :name, :avatar

  def name
    serialization_options[:ar] && object.ar_name ? object.ar_name : object.name
  end

  def avatar
    serialization_options[:ar] && object.ar_avatar ? object.ar_avatar(:original) : (object.avatar_file_name ? object.avatar(:original) : object.company.avatar(:original))
  end
end
