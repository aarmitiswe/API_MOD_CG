class AddFieldsToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :gender, :integer
    add_column :jobs, :marital_status, :string
    add_column :jobs, :age_range, :string
    add_column :jobs, :languages, :string
    add_column :jobs, :nationality_id, :integer
    add_column :jobs, :join_date, :date
    add_reference :jobs, :visa_status, index: true, foreign_key: :visa_status_id
  end
end
