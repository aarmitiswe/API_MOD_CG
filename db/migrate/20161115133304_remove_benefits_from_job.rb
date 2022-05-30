class RemoveBenefitsFromJob < ActiveRecord::Migration
  def change
    remove_column :jobs, :benefits, :string
  end
end
