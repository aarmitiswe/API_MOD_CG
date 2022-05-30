class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :name
      t.string :type, null: false
      t.references :parent_organization, references: :organizations

      t.timestamps null: false
    end

    add_foreign_key :organizations, :organizations, column: :parent_organization_id
  end
end
