class NewFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :ext_employer_id, :string
    add_column :users, :start_date, :date
    add_column :users, :end_date, :date

  end
end
