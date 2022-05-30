class AddInterviewDesignationToInterview < ActiveRecord::Migration
  def change
    add_column :interviews, :interviewer_designation, :string
  end
end
