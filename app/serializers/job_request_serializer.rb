class JobRequestSerializer < ActiveModel::Serializer
  attributes :id, :total_number_vacancies, :status_approval_one, :status_approval_two, :status_approval_three,
             :status_approval_four, :status_approval_five, :date_approval_one, :date_approval_two, :date_approval_three,
             :date_approval_four, :date_approval_five, :rejection_reason_one, :rejection_reason_two, :rejection_reason_three,
             :rejection_reason_four, :rejection_reason_five, :deleted, :request_for_approval, :position_id,
             :budgeted_vacancy_id
  has_one :job, serializer: JobAuthorizedSerializer, root: :job
  has_one :hiring_manager
  has_one :grade

end


