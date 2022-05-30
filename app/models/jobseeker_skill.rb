class JobseekerSkill < ActiveRecord::Base

  belongs_to :jobseeker
  belongs_to :skill

  # accepts_nested_attributes_for :jobseeker

  after_create :increase_skill_weight
  after_destroy :decrease_skill_weight

  validates_uniqueness_of :jobseeker_id, scope: :skill_id
  validates_presence_of :jobseeker_id, :skill_id

  LEVEL = %w(Beginner Intermediate Expert)

  def increase_skill_weight
    self.skill.update_column(:weight, (self.skill.weight || 0) + 1) if self.skill.present?
  end

  def decrease_skill_weight
    self.skill.update_column(:weight, (self.skill.weight || 1) - 1) if self.skill.present?
  end

  def level_name
    JobseekerSkill::LEVEL[self.level - 1]
  end
end
