class SectorSerializer < ActiveModel::Serializer
  attributes :id, :name, :jobs_count, :display_order

  def jobs_count
    object.get_jobs_count
  end

  def name
    serialization_options[:ar] && object.ar_name ? object.ar_name : object.name
  end
end
