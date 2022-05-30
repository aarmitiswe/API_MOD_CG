class PackageBroadcast < ActiveRecord::Base

  def self.create_production_packages
    if PackageBroadcast.count != 6
      PackageBroadcast.create([
                                  {num_credits: 1, price: 5.0, currency: "USD"},
                                  {num_credits: 5, price: 15.0, currency: "USD"},
                                  {num_credits: 10, price: 25.0, currency: "USD"},
                                  {num_credits: 20, price: 35.0, currency: "USD"},
                                  {num_credits: 30, price: 50.0, currency: "USD"},
                                  {num_credits: 50, price: 75.0, currency: "USD"},
                              ])
    end
  end
end
