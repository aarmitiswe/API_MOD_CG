class BoardingRequisition < ActiveRecord::Base
  belongs_to :job_application
  belongs_to :user
  belongs_to :boarding_form

  after_save :send_notification

  scope :approved, -> { where(status: "approved") }
  scope :rejected, -> { where(status: "rejected") }
  scope :sent, -> { where(status: "sent") }

  STATUSES = %w(approved rejected sent)

  STATUSES.each do |status_val|
    define_method("is_#{status_val}?") { self.status == status_val }
  end


  def send_notification
    if self.is_approved?
      self.boarding_form.send_request_to_recruitment_manager
    end
  end
end
