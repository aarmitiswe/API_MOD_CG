class CreateCompanyMembers < ActiveRecord::Migration
  def change
    create_table :company_members do |t|
      t.string :name
      t.string :position
      t.string :facebook_url
      t.string :twitter_url
      t.string :linkedin_url
      t.string :google_plus_url
      t.references :company, index: true, foreign_key: :company_id

      t.timestamps null: false
    end
  end
end
