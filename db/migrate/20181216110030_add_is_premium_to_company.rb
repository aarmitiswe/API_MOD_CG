class AddIsPremiumToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :is_premium, :boolean, default: false
  end
end
