FactoryGirl.define do
  factory :employer_notification do
    notifiable_id 1
    notifiable_type "MyString"
    user nil
    finished_action "MyString"
    needed_action "MyString"
    email_template nil
    subject "MyString"
    content "MyText"
  end
end
