class AddCountryToCity < ActiveRecord::Migration
  def change
    add_reference :cities, :country, index: true, foreign_key: :country_id
  end
end
