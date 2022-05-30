class OfferApprover < ActiveRecord::Base
  include Pagination

  belongs_to :user

  # POSITIONS = ['Hiring Manager', 'General HR Manager', 'Chief of Staff Minister of Defense', 'Assistant Minister of Defense']
  POSITIONS = ['Sourcing Team Manager', 'Recruitment Manager', 'Hiring Manager', 'Executive Office']

  scope :order_by_level, -> { order(:level) }
  scope :is_old_offer, -> { where("created_at < ?", Date.parse('7 Mar, 2022').beginning_of_day) }
  scope :is_new_offer, -> { where.not(position: 'Sourcing Team Manager').where("created_at >= ?", Date.parse('7 Mar, 2022').beginning_of_day) }

  after_save :set_level

  def set_level
    self.update_column(:level, POSITIONS.find_index(self.position) + 1) if POSITIONS.include?(self.position)
  end

  # approvers = [{email: 'myakout@bloovo.com', position: 'Hiring Manager'}]
  def self.create_default_approvers approvers=nil
    approvers ||= Rails.application.secrets['OfferApprovers'] || []
    approvers.each do |approver|
      user = User.find_by_email(approver["email"])
      if user.present? && OfferApprover.find_by_user_id(user.id).nil?
        OfferApprover.create(user_id: user.id, position: approver["position"])
      end
    end
  end
end
