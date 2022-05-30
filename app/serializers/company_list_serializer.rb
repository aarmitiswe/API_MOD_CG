class CompanyListSerializer < ActiveModel::Serializer
  delegate :current_user, to: :scope

  attributes :id,
             :name,
             :establishment_date,
             :profile_image,
             :hero_image,
             :followers_count,
             :opened_jobs_count,
             :is_follow_by_current_user,
             :avatar

  has_one :sector
  has_one :current_city
  has_one :current_country

  def is_follow_by_current_user
    object.is_follow_by_user current_user
  end
end
