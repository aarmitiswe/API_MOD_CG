namespace :subscription do
  desc "create default subscription"
  task create_default_subscription: :environment do
    if Package.count.zero?
      Package.create(name: "Default Package",
        description: "Access to MOD System", price: 10.0, currency: "SAR", job_postings: nil)
    end

    if CompanySubscription.count.zero?
      CompanySubscription.create(company_id: Company.first.id, package_id: Package.first.id,
        expires_at: Date.today + 1.year, job_posts_bank: nil, active: true,
        activation_code: Base64.encode64((Date.today).beginning_of_day.to_i.to_s).first(12),
        activated_at: Date.today)
    end
  end
end
