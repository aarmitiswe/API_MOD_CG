class AddLatitudeAndLongitudeToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :latitude, :string
    add_column :companies, :longitude, :string
  end
end
