class EvaluationSubmit < ActiveRecord::Base
  belongs_to :user
  belongs_to :job_application
  belongs_to :evaluation_form

  has_many :evaluation_answers, dependent: :destroy

  accepts_nested_attributes_for :evaluation_answers, allow_destroy: true

  has_many :evaluation_submit_requisitions, -> { order(created_at: :asc) }, dependent: :destroy

  validates_uniqueness_of :evaluation_form_id, scope: [:user_id, :job_application_id]

  # after_save :send_notification_to_hiring_manager
  after_save :create_evaluation_submit_requisitions_for_submits

  def status
    self.evaluation_submit_requisitions.all?{|req| req.is_approved? } ? EvaluationSubmitRequisition::APPROVE_STATUS : EvaluationSubmitRequisition::SENT_STATUS
  end

  def organization
    self.job_application.job.organization
  end

  def is_all_submitted?
    self.job_application.is_submitted_by_all_interviewers? && !self.evaluation_answers.blank? && self.job_application.evaluation_submits.all?{|s| s.total_score.present? }
  end

  def send_notification_to_hiring_manager
    self.job_application.review_evaluation_form if self.is_all_submitted?
  end

  def get_highest_organization ancestor_organizations, organization
    all_ancestors = organization.all_parent_orgnizations
    common_organizations = all_ancestors & ancestor_organizations
    res = common_organizations.blank? ? organization : common_organizations.first
    res
  end

  def get_answer_by_question_name question_name
    question = EvaluationQuestion.find_by_name(question_name)
    self.evaluation_answers.find_by(evaluation_question_id: question.id).answer_text
  end

  def create_evaluation_submit_requisitions_for_submits
    return if self.total_score.blank? || self.evaluation_answers.blank? && !self.is_all_submitted?

    self.job_application.evaluation_submits.each do |evaluation_submit|
      evaluation_submit.generate_evaluation_submit_requisitions
    end
  end

  def generate_evaluation_submit_requisitions

    selected_organization = get_highest_organization(self.user.organizations, self.organization)

    all_managers_with_organization = selected_organization.all_managers_with_organization_for_evaluation_submits
    first_requisition = nil
    all_managers_with_organization.each do |org_user_obj|
      next unless org_user_obj[:manager].is_approver
      # is_approved = org_user_obj[:manager].id == self.user_id
      is_approved = false

      if org_user_obj[:organization].nil? || (org_user_obj[:organization].present? && !(["Executive Office", "ExecutiveOffice"].include?(org_user_obj[:organization].organization_type.try(:name))))

        current = EvaluationSubmitRequisition.create(user_id: org_user_obj[:manager].id,
                                     organization_id: org_user_obj[:organization].try(:id),
                                     job_application_id: self.job_application_id,
                                     evaluation_form_id: self.evaluation_form_id,
                                     evaluation_submit_id: self.id,
                                     status: (is_approved ? EvaluationSubmitRequisition::APPROVE_STATUS : EvaluationSubmitRequisition::SENT_STATUS),
                                     active: is_approved,
                                     approved_at: is_approved ? DateTime.now : nil)

        first_requisition ||= current
      end
    end
    first_requisition.check_next_requisition
  end
end
