class HiringManagerSerializer < ActiveModel::Serializer
  attributes :id, :approver_one, :num_approvers, :hiring_manager_type
  has_one :section
  has_one :new_section
  has_one :office
  has_one :department
  has_one :unit
  has_one :grade
  has_one :approver_two
  has_one :approver_three
  has_one :approver_four
  has_one :approver_five
  has_many :hiring_manager_owners
end
