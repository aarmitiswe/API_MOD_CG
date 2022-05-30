class AddActivationCodeToCompanySubscription < ActiveRecord::Migration
  def change
    add_column :company_subscriptions, :activation_code, :string
    add_column :company_subscriptions, :activated_at, :date
  end
end
