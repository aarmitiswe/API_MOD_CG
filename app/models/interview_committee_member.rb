class InterviewCommitteeMember < ActiveRecord::Base
  include Pagination
  belongs_to :interview
  belongs_to :user

  def full_name
    self.user.full_name
  end

  def position
    self.user.role.try("name") || "NA"
  end
end

