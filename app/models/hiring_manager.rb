class HiringManager < ActiveRecord::Base
  include Pagination
  belongs_to :section
  belongs_to :new_section
  belongs_to :office
  belongs_to :department
  belongs_to :unit
  belongs_to :grade
  belongs_to :approver_one, class_name: User, foreign_key: 'approver_one_id'
  belongs_to :approver_two, class_name: User, foreign_key: 'approver_two_id'
  belongs_to :approver_three, class_name: User, foreign_key: 'approver_three_id'
  belongs_to :approver_four, class_name: User, foreign_key: 'approver_four_id'
  belongs_to :approver_five, class_name: User, foreign_key: 'approver_five_id'

  has_many :hiring_manager_owners, dependent: :destroy
  accepts_nested_attributes_for :hiring_manager_owners, allow_destroy: true

  scope :order_by_desc, -> {  order("id DESC") }
  scope :active, -> { where('hiring_managers.deleted = ?', false) }

  after_commit :set_company_owner_as_hiring_manager




  def set_company_owner_as_hiring_manager
    if self.hiring_manager_owners.where(user_id: User.company_owners.first.id).count == 0
      HiringManagerOwner.create(user_id: User.company_owners.first.id, hiring_manager_id: self.id)
    end

  end

end
