class OrganizationUser < ActiveRecord::Base
  belongs_to :organization
  belongs_to :user

  # validates :organization_id, uniqueness: { scope: :user_id }
  # validates_presence_of :organization_id, :user_id
end
