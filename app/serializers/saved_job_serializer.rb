class SavedJobSerializer < ActiveModel::Serializer
  attributes :id, :user

  has_one :jobseeker
  has_one :job, serializer: JobListSerializer

  def jobseeker
    {id: object.jobseeker.id}
  end

  def user
    {id: object.jobseeker.user.id}
  end
end
