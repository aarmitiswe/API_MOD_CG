class HiringManagerOwner < ActiveRecord::Base
  include Pagination
  belongs_to :user
  belongs_to :hiring_manager
end
