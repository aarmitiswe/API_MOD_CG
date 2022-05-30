FactoryGirl.define do
  factory :comment do
    content "MyString"
    is_deleted false
    is_active false
    user nil
    blog nil
  end
end
