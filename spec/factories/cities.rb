FactoryGirl.define do
  factory :city do
    name { FFaker::Address.state }
    latitude { FFaker::Geolocation.lat }
    longitude { FFaker::Geolocation.lng }
    association :followed_by_state, factory: :state
  end
end
