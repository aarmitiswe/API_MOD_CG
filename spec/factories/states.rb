FactoryGirl.define do
  factory :state do
    name { FFaker::Address.state }
    latitude { FFaker::Geolocation.lat }
    longitude { FFaker::Geolocation.lng }
    association :followed_by_country, factory: :country
  end
end
