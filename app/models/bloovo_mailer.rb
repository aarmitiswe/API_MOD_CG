class BloovoMailer
  include SendInvitation

  def send_demo_email(payload)

    vars = [{name: "contactperson", content: payload[:contact_person]},
     {name: "phonenumber", content: payload[:phone_number]},
     {name: "country", content: Country.find(payload[:country].to_i).name},
     {name: "companyname", content: payload[:company_name]},
     {name: "email", content: payload[:email]},
     {name: "reason", content: payload[:reason]}]

    subject = "Demo Request by #{payload[:contact_person]}"

    email_to = Rails.application.secrets['DEMO_RECEIVERS']

    email_from = Rails.application.secrets['SENDER_EMAIL']

    self.send_email_template "request_demo"  ,vars ,email_to , email_from , subject
  end


  def send_ats_demo_email(payload)

    vars = [{name: "contactperson", content: payload[:contact_person]},
            {name: "phonenumber", content: payload[:phone_number]},
            {name: "country", content: Country.find(payload[:country].to_i).name},
            {name: "city", content: City.find(payload[:city].to_i).name},
            {name: "companyname", content: payload[:company_name]},
            {name: "email", content: payload[:email]},
            {name: "reason", content: payload[:reason]}]

    subject = "ATS Demo Request by #{payload[:contact_person]}"

    email_to = Rails.application.secrets['ATS_DEMO_RECEIVERS']

    email_from = Rails.application.secrets['SENDER_EMAIL']
    self.send_email_template "request_ats_demo"  ,vars ,email_to , email_from , subject
  end

  def send_event_email(payload)

    vars = [{name: "name", content: payload[:name]},
            {name: "company", content: payload[:company]},
            {name: "position", content: payload[:position]},
            {name: "department", content: payload[:department]},
            {name: "phone", content: payload[:mobile_phone]},
            {name: "email", content: payload[:email]}]

    subject = "Event registration Request by #{payload[:name]}"

    email_to = Rails.application.secrets['OWNER_TEAM']

    email_from = Rails.application.secrets['SENDER_EMAIL']

    self.send_email_template "meetup_event"  ,vars ,email_to , email_from , subject
  end

  def send_payment_successfull_employer(company,subscription)
    vars = [{name: "transaction_date", content: subscription.created_at.strftime("%d %B , %Y")},
            {name: "name", content: company.name},
            {name: "address1", content: company.address_line1},
            {name: "address2", content: company.address_line2},
            {name: "address3", content: "#{company.city_name} , #{company.country_name}"},
            {name: "package", content: "#{subscription.package.name} , #{subscription.package.description}"},
            {name: "price", content: "#{sprintf("%.2f",subscription.package.price)} USD"},
            {name: "expiry_date", content: subscription.expires_at.strftime("%d %B , %Y")},
            {name: "avatar", content: company.avatar.url}]



    subject = "BLOOVO.COM | Your Premium Subscription is Now Active"

    email_to = [{email: company.owner.email, name: company.owner.full_name}] | Rails.application.secrets['OWNER_TEAM']

    email_from = Rails.application.secrets['SENDER_EMAIL']

    self.send_email_template "payment_successfull_employer"  ,vars ,email_to , email_from , subject
  end

  def send_followers_notification(company)
    company_followers = company.company_followers
    email_to = []
    company_followers.each do |follower|
      email_to << {email: follower.email,name: follower.full_name}
    end

    vars = []
    company = self.companies.first
    msg_body = "New job posted by #{company.name}"
    self.send_email_template("job_post"  , vars ,email_to , email_from , "Job posted by #{company.name}")
  end

  def reminder_active_complete jobseeker
    vars = [
        {name: "full_name", content: jobseeker.full_name}
    ]

    subject = "BLOOVO.COM | Hundreds of New Jobs Waiting for You!"

    email_to = [{email: jobseeker.email, name: jobseeker.full_name}]

    email_from = Rails.application.secrets['SENDER_EMAIL']

    self.send_email_template "sent_active_complete", vars, email_to, email_from, subject
  end

  def send_holidays_mails template_name, receivers, subject
    email_from = Rails.application.secrets['SENDER_EMAIL']

    self.delay.send_email_template template_name, [], receivers, email_from, subject
  end
  
  def send_holidays_mails_as_annoncer template_name, receivers, subject
    email_from = Rails.application.secrets['SENDER_EMAIL']

    self.delay.send_email_template_as_annoncer template_name, [], receivers, email_from, subject
  end

  def send_mails_with_vars template_name, vars, receivers, subject
    email_from = Rails.application.secrets['SENDER_EMAIL']

    self.delay.send_email_template template_name, vars, receivers, email_from, subject
  end
end
