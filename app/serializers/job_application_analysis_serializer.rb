class JobApplicationAnalysisSerializer < ActiveModel::Serializer
  attributes :id, :applications_count, :unreviewed_applications_count,
             :reviewed_applications_count, :shortlisted_applications_count,
             :interviewed_applications_count, :successful_applications_count, :unsuccessful_applications_count,
             :not_matched_criteria_graduate_program_count, :selected_applications_count, :under_offer_applications_count,
             :accept_offer_applications_count, :shared_applications_count, :pass_interview_applications_count,
             :security_clearance_applications_count, :assessment_applications_count,
             :job_offer_applications_count, :onboarding_applications_count


  def applications_count
    object.job_applications.not_deleted.count
  end

  def unreviewed_applications_count
    object.job_applications.not_deleted.unreviewed.count
  end

  def reviewed_applications_count
    object.job_applications.not_deleted.reviewed.count
  end

  def shortlisted_applications_count
    object.job_applications.not_deleted.shortlisted.count
  end

  def interviewed_applications_count
    object.job_applications.not_deleted.interviewed.count
  end

  def successful_applications_count
    object.job_applications.not_deleted.successful.count
  end

  def unsuccessful_applications_count
    object.job_applications.not_deleted.unsuccessful.count
  end

  def not_matched_criteria_graduate_program_count
    Jobseeker.not_matched_criteria_graduate_program.count
  end

  def selected_applications_count
    object.job_applications.not_deleted.selected.count
  end

  def shared_applications_count
    object.job_applications.not_deleted.shared.count
  end

  def pass_interview_applications_count
    object.job_applications.not_deleted.pass_interview.count
  end

  def security_clearance_applications_count
    object.job_applications.not_deleted.security_clearance.count
  end

  def under_offer_applications_count
    object.job_applications.not_deleted.under_offer.count
  end

  def accept_offer_applications_count
    object.job_applications.not_deleted.accept_offer.count
  end

  def assessment_applications_count
    object.job_applications.not_deleted.assessment.count
  end

  def job_offer_applications_count
    object.job_applications.not_deleted.job_offer.count
  end

  def onboarding_applications_count
    object.job_applications.not_deleted.onboarding.count
  end
end
