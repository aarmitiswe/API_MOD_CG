class CybersourcePayment < ActiveRecord::Base

  def self.subscribe_package user, package
    if user.is_employer?

      subscription = CompanySubscription.create(company_id: user.company.id,
                                                package_id: package.id,
                                                active: true,
                                                job_posts_bank: package.job_postings,
                                                expires_at: DateTime.now + package.db_access_days.days)

      #send payment notification
      bloovo_mailer = BloovoMailer.new
      bloovo_mailer.send_payment_successfull_employer(user.company, subscription)

      return subscription
    else
      subscription = JobseekerPackageBroadcast.create(jobseeker_id: user.jobseeker.id, package_broadcast_id: package.id,
                                                      num_credits: package.num_credits, price: package.price)

      return subscription
    end
  end

  def self.send_payment_request user, credit_card, package

    gateway = ActiveMerchant::Billing::CyberSourceGateway.new(login: Rails.application.secrets[:cybersource_profile_id],
                                                              password: Rails.application.secrets[:cybersource_sop_key],
                                                              test:  !Rails.env.production?)

    response = gateway.purchase( package.price * 100, credit_card,
                                 { user_id: user.id,
                                   email: user.email,
                                   currency: "USD",
                                   decision_manager_enabled: "false" })



    response
  end

end