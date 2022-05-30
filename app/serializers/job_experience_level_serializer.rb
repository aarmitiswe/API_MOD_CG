class JobExperienceLevelSerializer < ActiveModel::Serializer
  attributes :id, :name

  def name
    serialization_options[:ar] && object.ar_level ? object.ar_level : object.level
  end
end
