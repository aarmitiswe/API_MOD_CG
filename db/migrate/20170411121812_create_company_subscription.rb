class CreateCompanySubscription < ActiveRecord::Migration
  def change
    create_table :company_subscriptions do |t|
      t.belongs_to :company
      t.belongs_to :package
      t.datetime :expires_at
      t.integer :job_posts_bank
      t.boolean :active

      t.timestamps
    end
  end
end
