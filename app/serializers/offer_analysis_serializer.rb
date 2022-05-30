class OfferAnalysisSerializer < ActiveModel::Serializer
  attributes :id, :basic_salary, :housing_allowance, :transportation_allowance, :monthly_salary,
             :percentage_increase, :level, :total_annual, :user_id
  has_many :offer_requisitions


end
