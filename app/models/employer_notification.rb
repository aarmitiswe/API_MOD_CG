class EmployerNotification < ActiveRecord::Base
  include Pagination
  belongs_to :user
  belongs_to :email_template

  scope :read, -> { where(status: 'read') }
  scope :unread, -> { where(status: 'unread') }

  validates_inclusion_of :status, in: %w( read unread ), allow_nil: true

  before_save :set_status

  def set_status
    self.status ||= 'unread'
  end
end
