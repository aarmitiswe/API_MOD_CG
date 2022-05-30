class AgeGroupSerializer < ActiveModel::Serializer
  attributes :id, :min_age, :max_age
end
