class EventVisitor < ActiveRecord::Base
  include SendInvitation

  def send_event_email(payload)

    vars = [{name: "contactperson", content: payload[:contact_person]},
            {name: "phonenumber", content: payload[:phone_number]},
            {name: "country", content: Country.find(payload[:country].to_i).name},
            {name: "companyname", content: payload[:company_name]},
            {name: "email", content: payload[:email]},
            {name: "reason", content: payload[:reason]}]

    subject = "Demo Request by #{payload[:contact_person]}"

    email_to = Rails.application.secrets['OWNER_TEAM']

    email_from = Rails.application.secrets['SENDER_EMAIL']

    self.send_email_template "request_demo"  ,vars ,email_to , email_from , subject
  end
end
