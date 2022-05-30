class AddFieldsToInterviewCommitteeMember < ActiveRecord::Migration
  def change
    add_reference :interview_committee_members, :interview, index: true, foreign_key: true
    add_reference :interview_committee_members, :user, index: true, foreign_key: true
  end
end
