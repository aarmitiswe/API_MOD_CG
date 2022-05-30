class BoardingFormSerializer < ActiveModel::Serializer
  attributes :id, :title, :owner_position, :effective_joining_date, :copy_number, :expected_joining_date, :signed_joining_document, :signed_stc_document, :support_management_checked_at, :evaluation_performance_checked_at, :it_management_checked_at, :business_service_management_checked_at, :security_management_checked_at, :mod_session_checked_at
  has_many :boarding_requisitions
end
