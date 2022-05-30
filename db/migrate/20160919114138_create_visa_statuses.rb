class CreateVisaStatuses < ActiveRecord::Migration
  def change
    create_table :visa_statuses do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
