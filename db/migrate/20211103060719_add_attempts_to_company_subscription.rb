class AddAttemptsToCompanySubscription < ActiveRecord::Migration
  def change
    add_column :company_subscriptions, :attempts, :integer, default: 0
    add_column :company_subscriptions, :lock_at, :datetime
  end
end
