class AddArAreaToFunctionalArea < ActiveRecord::Migration
  def change
    add_column :functional_areas, :ar_area, :string
  end
end
