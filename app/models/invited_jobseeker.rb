class InvitedJobseeker < ActiveRecord::Base
  include SendInvitation

  belongs_to :jobseeker
  belongs_to :job

  validates_uniqueness_of :jobseeker_id, scope: :job_id

  after_create :send_invite_to_apply

  # This method to replace the %{} with real values
  def get_reply_template_values
    template_values = {
        URLRoot: Rails.application.secrets[:BACKEND],
        CompanyImg: self.job.company.avatar(:original),
        JobseekerImg: self.jobseeker.user.avatar(:original),
        JobseekerFullName: self.jobseeker.full_name,
        EmployerComment: self.msg_content,
        JobId: self.job_id,
        FrontURL: Rails.application.secrets[:FRONTEND],
        CompanyName: self.job.company.name,
        JobTitle: self.job.title,
        CreateDate: self.job.created_at.strftime("%d %b, %Y"),
        primaryColor: Rails.application.secrets[:ATS_CSS]["colors"]["primary"],
        secondaryColor: Rails.application.secrets[:ATS_CSS]["colors"]["secondary"],
        lightBg: Rails.application.secrets[:ATS_CSS]["colors"]["lightBg"],
        borderColor: Rails.application.secrets[:ATS_CSS]["colors"]["border"],
        MainLogo: "#{Rails.application.secrets[:BACKEND]}/email_templates/mail-logo.png",
        JobUrl: "#{Rails.application.secrets[:FRONTEND]}/#{self.job.country.try(:name).try(:parameterize)}/jobs/#{self.job.city.try(:name).try(:parameterize)}/#{self.job.sector.try(:name).try(:parameterize)}/#{self.job.title.try(:parameterize)}-#{self.job.id}"
    }
    template_values
  end

  def send_invite_to_apply
      self.delay.send_email "invite_to_apply", [{email: self.jobseeker.email, name: self.jobseeker.full_name}],
                            {
                                message_body: nil,
                                message_subject: "Invite to Apply for  #{self.job.title}",
                                template_values: self.get_reply_template_values
                            }
  end
end
