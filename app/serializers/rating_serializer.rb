class RatingSerializer < ActiveModel::Serializer
  attributes :id, :rate, :average_rating_for_jobseeker

  def average_rating_for_jobseeker
    object.jobseeker.average_rating
  end
end
