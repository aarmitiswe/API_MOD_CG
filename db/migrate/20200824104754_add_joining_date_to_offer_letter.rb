class AddJoiningDateToOfferLetter < ActiveRecord::Migration
  def change
    add_column :offer_letters, :joining_date, :date
  end
end
