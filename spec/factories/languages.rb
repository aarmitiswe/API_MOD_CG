FactoryGirl.define do
  factory :language do
    name { FFaker::Locale.language }
  end
end
