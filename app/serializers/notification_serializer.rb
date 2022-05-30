class NotificationSerializer < ActiveModel::Serializer
  attributes :id, :blog, :job, :poll_question, :newsletter, :visible_by_employer, :candidate

  def visible_by_employer
    return object.user.jobseeker.visible_by_employer? if object.user.is_jobseeker?
    nil
  end
end
