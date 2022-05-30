class AddSelectionCriteriaToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :country_required, :boolean
    add_column :jobs, :city_required, :boolean
    add_column :jobs, :nationality_required, :boolean
    add_column :jobs, :gender_required, :boolean
    add_column :jobs, :age_required, :boolean
    add_column :jobs, :years_of_exp_required, :boolean
    add_column :jobs, :experience_level_required, :boolean
    add_column :jobs, :language_required, :boolean
  end
end
