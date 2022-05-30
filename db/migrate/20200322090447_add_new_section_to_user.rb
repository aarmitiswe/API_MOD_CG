class AddNewSectionToUser < ActiveRecord::Migration
  def change
  	 add_reference :users, :new_section, index: true, foreign_key: true
  end
end
