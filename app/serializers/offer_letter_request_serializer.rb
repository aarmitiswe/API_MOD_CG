class OfferLetterRequestSerializer < ActiveModel::Serializer
  attributes :id, :basic_salary, :housing_salary, :transportation_salary, :mobile_allowance_salary,
             :total_salary, :offer_letter_type, :status_approval_one, :status_approval_two,
             :status_approval_three, :status_approval_four, :status_approval_five, :date_approval_one,
             :date_approval_two, :date_approval_three, :date_approval_four, :date_approval_five, :comment_approval_one,
             :comment_approval_two, :comment_approval_three, :comment_approval_four, :comment_approval_five,
             :reply_jobseeker, :status_jobseeker, :end_date, :relocation_allowance, :title, :start_date, :job_grade,
             :joining_date
  has_one :job_application_status_change, serializer: JobApplicationStatusChangeNoRequestSerializer
  has_one :offer_letter
  has_one :hiring_manager
end
