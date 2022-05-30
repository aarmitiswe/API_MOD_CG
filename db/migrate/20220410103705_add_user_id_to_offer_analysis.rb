class AddUserIdToOfferAnalysis < ActiveRecord::Migration
  def change
    add_reference :offer_analyses, :user, index: true, foreign_key: :user_id
  end
end
