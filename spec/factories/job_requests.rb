FactoryGirl.define do
  factory :job_request do
    job nil
    hiring_manager nil
    total_number_vacancies 1
    status_approval_one "MyString"
    status_approval_two "MyString"
    status_approval_three "MyString"
    status_approval_four "MyString"
    status_approval_five "MyString"
  end
end
