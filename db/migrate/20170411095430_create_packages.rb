class CreatePackages < ActiveRecord::Migration
  def change
    create_table :packages do |t|
      t.string :name
      t.string :description
      t.float :price
      t.string :currency
      t.integer :job_postings
      t.integer :db_access_days
      t.boolean :employer_logo
      t.boolean :branding
      t.string :details
      t.timestamp
    end
  end
end
