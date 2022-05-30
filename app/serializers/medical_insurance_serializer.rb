class MedicalInsuranceSerializer < ActiveModel::Serializer
  attributes :id, :english_name, :arabic_name, :birthday, :id_number, :start_date, :end_date, :relation
  has_one :jobseeker
  has_one :nationality
end
