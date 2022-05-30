class JobApplicationStatusChangeSerializer < ActiveModel::Serializer
  delegate :current_user, to: :scope

  attributes :id, :comment, :created_at, :employer_id, :employer_name, :jobseeker_id, :offer_requisition_status,
             :on_boarding_status, :watheeq, :performance_evaluation, :on_boarding_session, :it_management,
             :business_service_management, :security_management, :terminated_at, :offer_recruiter_id

  has_many :interviews
  has_many :offer_letters
  has_one :candidate_information_document
  has_one :assessments
  has_one :job_application_status
  has_many :offer_analyses
  has_many :salary_analyses
  has_many :boarding_forms

  def employer_name
    User.find_by_id(object.employer_id).try(:full_name)
  end

  def terminated_at
    object.job_application.terminated_at
  end

  def offer_recruiter_id
    object.offer_analyses.try(:first).try(:user_id)
  end


end
