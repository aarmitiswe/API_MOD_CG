class CompanyFollowersGraphSerializer < ActiveModel::Serializer
  include PieChartHelper

  attributes :id, :followers_by_country, :followers_by_age,
             :total_count, :followers_by_gender, :followers_by_nationality

  def followers_by_country
    follower_hash = object.followers_by_country
    # This line call two methods (collect_small_values: to select max 5) &
    # calculate_percentage: to convert values to percentage
    pie_chart_obj = calculate_percentage collect_small_values(follower_hash)
    pie_chart_obj[:labels].map!{ |id| (serialization_options[:ar] && serialization_options[:ar] == 'true' ? Country.find_by_id(id).try(:ar_name) : Country.find_by_id(id).try(:name)) || id}
    pie_chart_obj
  end

  def followers_by_nationality
    follower_hash = object.followers_by_nationality
    # This line call two methods (collect_small_values: to select max 5) &
    # calculate_percentage: to convert values to percentage
    pie_chart_obj = calculate_percentage collect_small_values(follower_hash)
    pie_chart_obj[:labels].map!{ |id| (serialization_options[:ar] && serialization_options[:ar] == 'true' ? Country.find_by_id(id).try(:ar_name) : Country.find_by_id(id).try(:name)) || id }
    pie_chart_obj
  end


  def total_count
    object.followers.count
  end

  def followers_by_gender
    {
        male: object.followers.male.count,
        female: object.followers.female.count
    }
  end

  # year_count = {"01-01-2016": 5, "01-01-2015": 33}
  def followers_by_age
    year_count = object.followers_by_age
    # build_age_slices: to count records for each age group
    # calculate_percentage: to convert count to percentage
    calculate_percentage build_age_slices(year_count)
  end
end