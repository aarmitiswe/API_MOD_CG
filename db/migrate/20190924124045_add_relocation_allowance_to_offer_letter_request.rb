class AddRelocationAllowanceToOfferLetterRequest < ActiveRecord::Migration
  def change
    add_column :offer_letter_requests, :relocation_allowance, :float
  end
end
