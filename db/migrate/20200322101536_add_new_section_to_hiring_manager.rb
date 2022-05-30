class AddNewSectionToHiringManager < ActiveRecord::Migration
  def change
  	 add_reference :hiring_managers, :new_section, index: true, foreign_key: true
  end
end
