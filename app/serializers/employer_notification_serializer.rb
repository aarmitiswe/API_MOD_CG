class EmployerNotificationSerializer < ActiveModel::Serializer
  attributes :id, :notifiable_id, :notifiable_type, :finished_action, :needed_action, :subject, :content, :status,
             :page_url, :created_at
  has_one :user
end
