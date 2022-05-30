FactoryGirl.define do
  factory :permission do
    user nil
    controller_name "MyString"
    subject_class "MyString"
    action "MyString"
  end
end
