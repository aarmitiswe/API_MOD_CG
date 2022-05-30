class CreateDemoRequests < ActiveRecord::Migration
  def change
    create_table :demo_requests do |t|
      t.string :company_name
      t.string :country
      t.string :contact_person
      t.string :phone_number
      t.string :email
      t.string :reason
      t.timestamps
    end
  end
end
