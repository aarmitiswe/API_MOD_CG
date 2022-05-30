class Note < ActiveRecord::Base
  belongs_to :job_application
  belongs_to :company_user

  def author_name
    self.company_user.user.full_name
  end
end
