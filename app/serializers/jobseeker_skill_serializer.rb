class JobseekerSkillSerializer < ActiveModel::Serializer
  attributes :id, :name, :level

  def name
    object.skill.name
  end

  def id
    object.skill.id
  end
end
