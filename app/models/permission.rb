class Permission < ActiveRecord::Base
  belongs_to :user
  scope :interview_only, -> { where(name: 'interview_only') }
  scope :shortlist_only, -> { where(name: 'shortlist_only') }
  scope :offer_only, -> { where(name: 'offer_only') }
  scope :update_own_job, -> { where(name: 'update_own_job') }
  scope :update_other_job, -> { where(name: 'update_other_job') }
  scope :activate_deactivate_job, -> { where(name: 'activate_deactivate_job') }
  scope :destroy_own_job, -> { where(name: 'destroy_own_job') }
  scope :destroy_other_job, -> { where(name: 'destroy_other_job') }
end
