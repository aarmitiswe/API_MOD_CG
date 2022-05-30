class JobseekerProfileViewSerializer < ActiveModel::Serializer
  include ActionView::Helpers::DateHelper
  include DateHelper
  delegate :current_user, to: :scope

  attributes :id, :view_date, :duration

  has_one :company, serializer: CompanyListSerializer

  def duration
    remove_unwanted_words(distance_of_time_in_words_to_now(object.view_date.to_date)).titleize
  end

  def company
    Company.find_by_id(object.company_id)
  end
end
