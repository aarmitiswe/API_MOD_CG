class CompanySubscription < ActiveRecord::Base
  MAX_ATTEMPTS = 3
  #this model tells if company has purchased and subscription. Whenever a company pay for a subscription this table will have entery with validity

  scope :active, -> {where(active: true)}
  belongs_to :company
  belongs_to :package

  validate :check_valid_activation_code

  def encoded_activated_at
    Base64.encode64(self.activated_at.beginning_of_day.to_i.to_s)
  end

  def valid_activation_code
    is_valid = self.activated_at.present? && self.activation_code.present? &&
    Date.today <= (self.activated_at + 1.year) &&
    self.activation_code.length == 12 && self.encoded_activated_at.include?(self.activation_code)

    if is_valid
      self.update_columns(attempts: 0, lock_at: nil)
    end

    is_valid
  end

  def check_valid_activation_code
    if self.attempts >= MAX_ATTEMPTS && self.lock_at.present? && self.lock_at < DateTime.now
      self.errors.add(:lock_at, " can't try again before #{self.lock_at}")
    elsif self.lock_at.present? && self.lock_at > DateTime.now
      self.update_columns(attempts: 0, lock_at: nil)
    end

    if !self.valid_activation_code
      self.update_column(:attempts, self.attempts + 1)
      if self.attempts >= MAX_ATTEMPTS
        self.update_column(:lock_at, DateTime.now + 1.day)
      end
      self.errors.add(:activation_code, " is not valid")
    end
  end
end
