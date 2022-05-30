class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      # Company Data
      t.string :name
      t.text :summary
      t.date :establishment_date
      t.string :website
      t.string :profile_image
      t.string :hero_image

      # Contact Information
      t.references :current_city
      t.references :current_country
      t.string :address_line1
      t.string :address_line2
      t.string :phone
      t.string :fax
      t.string :contact_email
      t.string :po_box
      t.string :contact_person

      # Social Links
      t.string :google_plus_page_url
      t.string :linkedin_page_url
      t.string :facebook_page_url
      t.string :twitter_page_url

      # action control
      t.boolean :active
      t.boolean :deleted



      # Foreign Keys
      t.references :sector, index: true
      t.references :company_size, index: true
      t.references :company_type, index: true
      t.references :company_classification, index:true

      t.timestamps null: false
    end
    add_foreign_key :companies, :sectors
    add_foreign_key :companies, :company_sizes
    add_foreign_key :companies, :company_types
    add_foreign_key :companies, :company_classifications

  end
end
