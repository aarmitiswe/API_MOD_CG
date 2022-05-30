class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :blog

  validates_presence_of :content, :user_id, :blog_id

  # before_create :set_not_deleted

  scope :deleted, -> { where(is_deleted: true) }
  scope :active, -> { where(is_active: true) }

  protected
    def set_not_deleted
      self.is_deleted = false
    end
end
