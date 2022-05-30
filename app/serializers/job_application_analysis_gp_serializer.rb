class JobApplicationAnalysisGpSerializer < ActiveModel::Serializer
  attributes :id, :applications_count, :unreviewed_applications_count,
             :reviewed_applications_count, :shortlisted_applications_count,
             :interviewed_applications_count, :successful_applications_count, :unsuccessful_applications_count,
             :not_matched_criteria_graduate_program_count, :selected_applications_count, :under_offer_applications_count,
             :accept_offer_applications_count

  def applications_count
    object.job_applications.matched_criteria_graduate_program(object).count
  end

  def unreviewed_applications_count
    object.job_applications.matched_criteria_graduate_program(object).unreviewed.count
  end

  def reviewed_applications_count
    object.job_applications.matched_criteria_graduate_program(object).reviewed.count
  end

  def shortlisted_applications_count
    object.job_applications.matched_criteria_graduate_program(object).shortlisted.count
  end

  def interviewed_applications_count
    object.job_applications.matched_criteria_graduate_program(object).interviewed.count
  end

  def successful_applications_count
    object.job_applications.matched_criteria_graduate_program(object).successful.count
  end

  def unsuccessful_applications_count
    object.job_applications.matched_criteria_graduate_program(object).unsuccessful.count
  end

  def not_matched_criteria_graduate_program_count
    Jobseeker.not_matched_criteria_graduate_program.count
  end

  def selected_applications_count
    object.job_applications.selected.count
  end

  def under_offer_applications_count
    object.job_applications.under_offer.count
  end

  def accept_offer_applications_count
    object.job_applications.accept_offer.count
  end
end