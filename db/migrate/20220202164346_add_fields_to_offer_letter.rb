class AddFieldsToOfferLetter < ActiveRecord::Migration
  def change
    add_column :offer_letters, :candidate_dob, :date
    add_column :offer_letters, :candidate_second_name, :string
    add_column :offer_letters, :candidate_third_name, :string
    add_column :offer_letters, :candidate_birth_city, :string
    add_column :offer_letters, :candidate_birth_country, :string
    add_column :offer_letters, :candidate_nationality, :string
    add_column :offer_letters, :candidate_religion, :string
    add_column :offer_letters, :candidate_gender, :string
  end
end
