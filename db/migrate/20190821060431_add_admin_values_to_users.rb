class AddAdminValuesToUsers < ActiveRecord::Migration
  def change
    add_reference :users, :section, index: true, foreign_key: true
    add_reference :users, :department, index: true, foreign_key: true
    add_reference :users, :office, index: true, foreign_key: true
    add_reference :users, :unit, index: true, foreign_key: true
    add_reference :users, :grade, index: true, foreign_key: true
  end
end
