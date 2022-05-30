class Folder < ActiveRecord::Base
  include Pagination

  LIMIT_SUB_FOLDERS = 5

  belongs_to :creator, class_name: User, foreign_key: 'creator_id'
  belongs_to :parent, class_name: Folder, foreign_key: 'parent_id'
  has_many :sub_folders, foreign_key: :parent_id, class_name: Folder, source: :folder, dependent: :destroy
  has_many :top_five_sub_folders, -> { order(created_at: :desc).limit(LIMIT_SUB_FOLDERS) }, foreign_key: :parent_id, class_name: Folder, source: :folder, dependent: :destroy


  has_many :assigned_folders, dependent: :destroy
  has_many :assigned_users, through: :assigned_folders, class_name: User, source: :user
  has_many :users, through: :assigned_folders
  accepts_nested_attributes_for :assigned_folders

  has_many :jobseeker_folders, dependent: :destroy
  has_many :jobseekers, through: :jobseeker_folders

  validates_presence_of :name, :creator
  validates_uniqueness_of :name, scope: [:parent_id, :level]
  validates_inclusion_of :level, in: 1..3

  before_validation :set_level

  # Scopes
  scope :first_level, -> { where(level: 1) }
  scope :second_level, -> { where(level: 2) }
  scope :third_level, -> { where(level: 3) }

  def company
    self.creator.company
  end

  def ancestors
    ancestors = []
    folder = self
    level = folder.level
    while level >= 1 do
      ancestors << folder
      folder = folder.parent
      level = folder ? folder.level : 0
    end
    ancestors
  end


  protected
    def set_level
      self.level = self.parent.present? ? (self.parent.level + 1) : 1
    end
end
