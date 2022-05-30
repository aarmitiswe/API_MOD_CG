class CountrySerializer < ActiveModel::Serializer
  attributes :id, :name, :jobs_count

  def jobs_count
    object.jobs.active.count
  end

  def name
    serialization_options[:ar] && object.ar_name ? object.ar_name : object.name
  end
end
