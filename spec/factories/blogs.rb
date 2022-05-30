FactoryGirl.define do
  factory :blog do
    title "MyString"
    description "MyText"
    is_active false
    is_deleted false
    avatar ""
    video ""
    video_link "MyString"
    views_count 1
    downloads_count 1
    company_user nil
  end
end
