class AddCreatorIdToJobApplication < ActiveRecord::Migration
  def change
    add_reference :job_applications, :user, index: true, foreign_key: :user_id
  end
end
