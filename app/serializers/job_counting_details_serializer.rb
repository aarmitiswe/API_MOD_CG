class JobCountingDetailsSerializer < ActiveModel::Serializer
  delegate :current_user, to: :scope
  
  attributes :id,
             :count_applications,
             :views_count,
             :probability_success,
             :current_user_rank

  def current_user_rank
    current_user.present? ? object.get_rank_jobseeker(current_user.jobseeker) : nil
  end
end
