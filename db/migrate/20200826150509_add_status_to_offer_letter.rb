class AddStatusToOfferLetter < ActiveRecord::Migration
  def change
    add_column :offer_letters, :jobseeker_status, :string
  end
end
