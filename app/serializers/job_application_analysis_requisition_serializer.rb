class JobApplicationAnalysisRequisitionSerializer < ActiveModel::Serializer
  attributes :id, :applications_count, :unreviewed_applications_count,
             :reviewed_applications_count, :shortlisted_applications_count,
             :interviewed_applications_count, :successful_applications_count,
             :unsuccessful_applications_count, :junk_applications_count,
             :selected_applications_count, :under_offer_applications_count,
             :accept_offer_applications_count, :shared_applications_count,
             :pass_interview_applications_count, :security_clearance_applications_count, :assessment_applications_count,
             :job_offer_applications_count, :onboarding_applications_count

  def applications_count
    object.job_applications.where(jobseeker_id: serialization_options[:applied_jobseeker_ids]).count
  end

  def unreviewed_applications_count
    object.job_applications.where(jobseeker_id: serialization_options[:applied_jobseeker_ids]).unreviewed.count
  end

  def reviewed_applications_count
    object.job_applications.where(jobseeker_id: serialization_options[:applied_jobseeker_ids]).reviewed.count
  end

  def shortlisted_applications_count
    object.job_applications.where(jobseeker_id: serialization_options[:applied_jobseeker_ids]).shortlisted.count
  end

  def interviewed_applications_count
    object.job_applications.where(jobseeker_id: serialization_options[:applied_jobseeker_ids]).interviewed.count
  end

  def successful_applications_count
    object.job_applications.where(jobseeker_id: serialization_options[:applied_jobseeker_ids]).successful.count
  end

  def unsuccessful_applications_count
    object.job_applications.where(jobseeker_id: serialization_options[:applied_jobseeker_ids]).unsuccessful.count
  end

  def selected_applications_count
    object.job_applications.where(jobseeker_id: serialization_options[:applied_jobseeker_ids]).selected.count
  end

  def under_offer_applications_count
    object.job_applications.where(jobseeker_id: serialization_options[:applied_jobseeker_ids]).under_offer.count
  end

  def accept_offer_applications_count
    object.job_applications.where(jobseeker_id: serialization_options[:applied_jobseeker_ids]).accept_offer.count
  end

  def junk_applications_count
    object.job_applications.where.not(jobseeker_id: serialization_options[:applied_jobseeker_ids]).count
  end

  def shared_applications_count
    object.job_applications.where(jobseeker_id: serialization_options[:applied_jobseeker_ids]).shared.count
  end

  def pass_interview_applications_count
    object.job_applications.where(jobseeker_id: serialization_options[:applied_jobseeker_ids]).pass_interview.count
  end

  def security_clearance_applications_count
    object.job_applications.where(jobseeker_id: serialization_options[:applied_jobseeker_ids]).security_clearance.count
  end

  def assessment_applications_count
    object.job_applications.where(jobseeker_id: serialization_options[:applied_jobseeker_ids]).assessment.count
  end

  def job_offer_applications_count
    object.job_applications.where(jobseeker_id: serialization_options[:applied_jobseeker_ids]).job_offer.count
  end

  def onboarding_applications_count
    object.job_applications.where(jobseeker_id: serialization_options[:applied_jobseeker_ids]).onboarding.count
  end

end