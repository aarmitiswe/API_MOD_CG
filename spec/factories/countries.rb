FactoryGirl.define do
  factory :country do
    name { FFaker::Address.country }
    iso { FFaker::Address.country_code }
    latitude { FFaker::Geolocation.lat }
    longitude { FFaker::Geolocation.lng }
  end
end
