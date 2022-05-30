class JobseekerTag < ActiveRecord::Base

  belongs_to :tag
  belongs_to :jobseeker
  after_create :increase_tag_weight
  after_destroy :decrease_tag_weight

  validates_presence_of :jobseeker_id, :tag_id
  validates_uniqueness_of :jobseeker_id, scope: :tag_id

  def increase_tag_weight
    self.tag.update_column(:weight, self.tag.weight + 1) if self.tag
  end

  def decrease_tag_weight
    self.tag.update_column(:weight, self.tag.weight - 1) if self.tag
  end
end
