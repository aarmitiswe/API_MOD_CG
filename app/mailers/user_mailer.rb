class UserMailer < ActionMailer::Base
  include SendInvitation

  def notification_email(user)
    mail(to: 'myakout@bloovo.com', from: Rails.application.secrets['SENDER_EMAIL'], body: 'TEST BODY', subject: 'SUBJECT')
  end

  def reset_password_instructions(record, token, opts = {})
    @token = token
    templates_values = {
      ResetPasswordUrl: "#{Rails.application.secrets[:FRONTEND]}/change-password?reset_password_token=#{@token}&email=#{record.email}",
      UserName: record.full_name,
      MainLogo: "#{Rails.application.secrets[:BACKEND]}/email_templates/mail-logo.png",
      primaryColor: Rails.application.secrets[:ATS_CSS]["colors"]["primary"],
      secondaryColor: Rails.application.secrets[:ATS_CSS]["colors"]["secondary"],
      lightBg: Rails.application.secrets[:ATS_CSS]["colors"]["lightBg"],
      borderColor: Rails.application.secrets[:ATS_CSS]["colors"]["border"],
      WebsiteName: Rails.application.secrets[:ATS_NAME]["website_name"],
    }

    self.send_email "reset_password",
                    [{email: record.email, name: record.full_name}],
                    {message_body: nil, template_values: templates_values}
  end
end
