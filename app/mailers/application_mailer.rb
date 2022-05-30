class ApplicationMailer < ActionMailer::Base
  # default from: "from@example.com"
  default from: Rails.application.secrets['SENDER_EMAIL']
  layout 'mailer'
end
