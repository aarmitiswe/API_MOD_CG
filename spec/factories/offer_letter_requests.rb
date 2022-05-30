FactoryGirl.define do
  factory :offer_letter_request do
    basic_salary 1.5
    housing_salary 1.5
    transportation_salary 1.5
    mobile_allowance_salary 1.5
    total_salary 1.5
    job_application_status_change nil
    offer_letter nil
    offer_letter_type "MyString"
    status_approval_one "MyString"
    status_approval_two "MyString"
    status_approval_three "MyString"
    status_approval_four "MyString"
    status_approval_five "MyString"
    date_approval_one "2019-09-18 18:16:17"
    date_approval_two "2019-09-18 18:16:17"
    date_approval_three "2019-09-18 18:16:17"
    date_approval_four "2019-09-18 18:16:17"
    date_approval_five "2019-09-18 18:16:17"
    comment_approval_one "MyText"
    comment_approval_two "MyText"
    comment_approval_three "MyText"
    comment_approval_four "MyText"
    comment_approval_five "MyText"
    reply_jobseeker "MyText"
    status_jobseeker "MyString"
  end
end
