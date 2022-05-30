class CreateOrganizationUsers < ActiveRecord::Migration
  def change
    create_table :organization_users do |t|
      t.references :organization, index: true, foreign_key: :organization_id
      t.references :user, index: true, foreign_key: :user_id
      t.boolean :is_manager, default: true

      t.timestamps null: false
    end
  end
end
