class CareerFairApplication < ActiveRecord::Base
  include Pagination
  include SendInvitation
  belongs_to :jobseeker
  belongs_to :career_fair

  validates_presence_of :jobseeker, :career_fair
  # validates :career_fair_id, uniqueness: {scope: :jobseeker_id}
  validates_uniqueness_of :career_fair_id, scope: :jobseeker_id
  after_save :send_join_event_email


  def send_join_event_email

    raw, enc = Devise.token_generator.generate(self.jobseeker.user.class, :reset_password_token)
    self.jobseeker.user.reset_password_token   = enc
    self.jobseeker.user.reset_password_sent_at = Time.now.utc
    self.jobseeker.user.save(validate: false)


    templates_values = {
        CreatedDate: self.created_at.strftime("%d %b, %Y"),
        RefNumber: self.jobseeker.user.id_6_digits,
        Subject: "You have successfully registered for “#{self.career_fair.title}” for “#{Rails.application.secrets[:ATS_NAME]["original_name"]}”",
        JobseekerFullName: self.jobseeker.user.full_name,
        CareerFairName: self.career_fair.title,
        CompanyName: Rails.application.secrets[:ATS_NAME]["original_name"],
        ResetPasswordURL: "#{Rails.application.secrets[:FRONTEND]}/change-password?reset_password_token=#{raw}&email=#{self.jobseeker.user.email}",
        Website: Rails.application.secrets[:FRONTEND],
        CompanyImg: "#{Rails.application.secrets[:BACKEND]}/email_templates/mail-logo.png",
        primaryColor: Rails.application.secrets[:ATS_CSS]["colors"]["primary"],
        secondaryColor: Rails.application.secrets[:ATS_CSS]["colors"]["secondary"],
        lightBg: Rails.application.secrets[:ATS_CSS]["colors"]["lightBg"],
        borderColor: Rails.application.secrets[:ATS_CSS]["colors"]["border"],
        WebsiteName: Rails.application.secrets[:ATS_NAME]["website_name"]
    }



     self.send_email "join_event",
                     [{email: self.jobseeker.user.email, name: self.jobseeker.user.full_name}],
                     {message_body: nil, template_values: templates_values,
                      message_subject: "You have successfully registered for “#{self.career_fair.title}” for “#{Rails.application.secrets[:ATS_NAME]["original_name"]}”"}






  end
end
