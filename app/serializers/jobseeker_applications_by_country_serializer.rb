class JobseekerApplicationsByCountrySerializer < ActiveModel::Serializer
  attributes :country, :percentage

  def country
    serialization_options[:ar] == "true" ? self.object.try(:first).try(:ar_name) : self.object.try(:first).try(:name)
  end

  def percentage
    self.object.try(:second)
  end
end
