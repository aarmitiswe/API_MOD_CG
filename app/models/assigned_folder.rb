class AssignedFolder < ActiveRecord::Base
  belongs_to :user
  belongs_to :folder

  validates_uniqueness_of :user_id, scope: :folder_id
  # TODO: Add folder_id in presence & user_id in group
  validates_presence_of :user_id
  # validates_inclusion_of :user_id, in: ->(assigned_folder) { assigned_folder.folder.creator.company.user_ids }
end
