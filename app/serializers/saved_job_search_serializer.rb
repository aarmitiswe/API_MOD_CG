class SavedJobSearchSerializer < ActiveModel::Serializer
  attributes :id, :title, :api_url, :web_url, :created_at
  has_one :jobseeker
  has_one :alert_type

  def jobseeker
    {id: object.jobseeker.id}
  end
end
