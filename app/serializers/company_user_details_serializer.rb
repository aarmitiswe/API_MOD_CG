# This serializer for users related to company
class CompanyUserDetailsSerializer < CompanyUserSerializer
  attributes :subscription, :notification_statistics

  has_one :company

  def subscription
    object.company.company_subscription.present? ? object.company.company_subscription : ""
  end

  def notification_statistics
    {
      all_notifications: object.employer_notifications.count,
      read_notifications: object.employer_notifications.read.count,
      unread_notifications: object.employer_notifications.unread.count
    }
  end
end
