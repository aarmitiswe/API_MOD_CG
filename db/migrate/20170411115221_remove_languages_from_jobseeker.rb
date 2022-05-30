class RemoveLanguagesFromJobseeker < ActiveRecord::Migration
  def change
    remove_column :jobseekers, :languages, :string
  end
end
