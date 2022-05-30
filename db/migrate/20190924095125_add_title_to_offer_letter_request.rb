class AddTitleToOfferLetterRequest < ActiveRecord::Migration
  def change
    add_column :offer_letter_requests, :title, :string
  end
end
