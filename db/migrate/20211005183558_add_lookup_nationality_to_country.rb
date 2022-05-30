class AddLookupNationalityToCountry < ActiveRecord::Migration
  def change
    add_column :countries, :lookup_nationality, :string
  end
end
