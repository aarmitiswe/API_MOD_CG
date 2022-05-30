class AddTimesToOfferLetter < ActiveRecord::Migration
  def change
    add_column :offer_letters, :shared_to_stc_at, :datetime
    add_column :offer_letters, :sent_to_candidate_at, :datetime
    add_column :offer_letters, :received_from_stc_at, :datetime
  end
end
