class AddColumnsToUser < ActiveRecord::Migration
  def change
    add_column :users, :gender, :integer
    add_column :users, :birthday, :date
    add_column :users, :profile_image, :string
    add_reference :users, :country, index: true
    add_reference :users, :state, index: true
    add_reference :users, :city, index: true

    add_column :users, :active, :boolean
    add_column :users, :deleted, :boolean
  end
end
