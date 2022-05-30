class CreateInterviewCommitteeMember < ActiveRecord::Migration
  def change
    create_table :interview_committee_members do |t|
      t.timestamps null: false
    end
  end
end
