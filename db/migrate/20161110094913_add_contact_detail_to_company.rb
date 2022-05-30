class AddContactDetailToCompany < ActiveRecord::Migration
  def change
    add_reference :companies, :country, index: true, foreign_key: :country_id
    add_reference :companies, :city, index: true, foreign_key: :city_id
  end
end
