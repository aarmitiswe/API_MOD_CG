class CreateOfferRequisitions < ActiveRecord::Migration
  def change
    create_table :offer_requisitions do |t|
      t.references :job_application, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.string :status
      t.string :comment

      t.timestamps null: false
    end
  end
end
