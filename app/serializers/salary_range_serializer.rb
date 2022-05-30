class SalaryRangeSerializer < ActiveModel::Serializer
  attributes :id, :salary_from, :salary_to
end
