class CareerFairSerializer < ActiveModel::Serializer
  delegate :current_user, to: :scope
  attributes :id, :title, :address, :active, :gender, :created_at,
             :updated_at, :logo_image, :logo_image_file_name, :applied_date, :from, :to


  has_one :city
  has_one :country


  def applied_date
    object.applied_date(current_user)
  end

  def gender
    (object.gender == 0) ? 'any' : (object.gender == 1) ? 'male' : 'female'
  end
end