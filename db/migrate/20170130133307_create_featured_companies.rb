class CreateFeaturedCompanies < ActiveRecord::Migration
  def change
    create_table :featured_companies do |t|
      t.references :company, index: true, foreign_key: :company_id

      t.timestamps null: false
    end
  end
end
