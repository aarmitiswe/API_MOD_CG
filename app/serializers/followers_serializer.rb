class FollowersSerializer < ActiveModel::Serializer
  include DateHelper

  attributes :id,  :first_name, :last_name, :position, :company_name, :experience,
             :city, :country, :user_id, :avatar, :default_resume, :video

  def position
    object.current_experience.try(:position)
  end

  def company_name
    object.current_experience.try(:company_name)
  end

  def city
    CitySerializer.new(object.user.city, root: :city).serializable_object(serialization_options)
  end

  def country
    CountrySerializer.new(object.user.country, root: :city).serializable_object(serialization_options)
  end

  def experience
    experience_dates = object.get_experience_dates
    subtract_to_years_months(experience_dates[:min_start_date],
                             experience_dates[:max_end_date])
  end

  def first_name
    object.user.try(:first_name)
  end

  def last_name
    object.user.try(:last_name)
  end
end