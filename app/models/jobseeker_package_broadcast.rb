class JobseekerPackageBroadcast < ActiveRecord::Base
  include SendInvitation

  belongs_to :jobseeker
  belongs_to :package_broadcast

  attr_accessor :is_used
  
  after_create :send_payment_confirmation

  def send_payment_confirmation
    vars = [
        {name: "transaction_day", content: self.created_at.strftime("%d %B")},
        {name: "transaction_year", content: self.created_at.strftime("%Y")},
        {name: "jobseeker_name", content: self.jobseeker.full_name},
        {name: "price", content: "#{sprintf("%.2f",self.package_broadcast.price)}"},
        {name: "num_credits", content: self.package_broadcast.num_credits},
        {name: "avatar", content: self.jobseeker.user.avatar.url},
        {name: "website", content: Rails.application.secrets["FRONTEND"]},
        {name: "credit_word", content: self.package_broadcast.num_credits > 1 ? "Credits" : "Credit"}
    ]



    subject = "Broadcast Your Profile | Payment Confirmation"

    recipients = [{email: self.jobseeker.user.email, name: self.jobseeker.full_name}] | Rails.application.secrets['OWNER_TEAM']

    email_from = Rails.application.secrets['SENDER_EMAIL']

    self.send_email_template "payment_successful_jobseeker", vars, recipients, email_from, subject
  end

  def self.update_all_nil_num_credits
    JobseekerPackageBroadcast.where(num_credits: nil).each do |jobseeker_package_broadcast|
      jobseeker_package_broadcast.update(num_credits: jobseeker_package_broadcast.package_broadcast.num_credits, price: jobseeker_package_broadcast.package_broadcast.price)
    end
  end
end
