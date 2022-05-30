class CareerFairApplicationSerializer < ActiveModel::Serializer

  attributes :id, :applied_date

  has_one :jobseeker, serializer: JobseekerListSerializer

  def applied_date
    object.created_at
  end
end