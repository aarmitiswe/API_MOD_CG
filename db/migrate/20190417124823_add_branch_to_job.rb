class AddBranchToJob < ActiveRecord::Migration
  def change
    add_reference :jobs, :branch, index: true, foreign_key: :branch_id
  end
end
