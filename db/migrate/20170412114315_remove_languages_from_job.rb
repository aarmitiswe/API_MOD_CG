class RemoveLanguagesFromJob < ActiveRecord::Migration
  def change
    remove_column :jobs, :languages, :string
  end
end
