FactoryGirl.define do
  factory :evaluation_submit_requisition do
    evaluation_form nil
    evaluation_submit nil
    job_application nil
    user nil
    status "MyString"
    active false
  end
end
