class JobApplicantsGraphSerializer < ActiveModel::Serializer
  delegate :current_user, to: :scope
  # attributes :monthly, :quarterly, :yearly, :counter_jobs_applicant_details, :job_applications_count
  attributes :counter_jobs_applicant_details, :job_applications_count,
  :count_by_recruiter, :hiring_ratio, :average_time_hiring, :average_time_security_clearance

  attr_accessor :job_application_ids, :jobs

  # organization_id_in: [1,2,3,4,5]
  def get_filtered_jobs
    # @jobs ||= object.jobs.ransack(serialization_options[:q]).result
    @jobs ||= current_user.jobs.ransack(serialization_options[:q]).result
    @jobs
  end

  def filtered_job_applications
    @job_applications ||= JobApplication.where(job_id: get_filtered_jobs.map(&:id))
    @job_applications
  end

  def filtered_job_application_ids
    # @job_application_ids ||= filtered_job_applications.where(job_id: get_filtered_jobs.map(&:id)).map(&:id)
    @job_application_ids ||= filtered_job_applications.map(&:id)
    @job_application_ids
  end

  def hiring_ratio
    # JobApplication.successful.count / [JobApplication.shortlisted.count, 1].max
    JobApplicationStatusChange.successful.count.to_f / [JobApplicationStatusChange.shortlisted.count.to_f, 1.0].max * 100.0
  end

  def average_time_hiring
    # Average Hiring Time (Total Time from Shortlisting to Offer Acceptance / Number of Hired People)
    avg = if filtered_job_applications.successful.count.zero?
            0
          else
            total_days = 0
            filtered_job_applications.each do |job_application|
              if !job_application.job_application_status_changes.shortlisted.blank? && !job_application.job_application_status_changes.job_offer.blank?
                shortlisted_date = job_application.job_application_status_changes.shortlisted.first.created_at.to_date
                job_offer_date = job_application.job_application_status_changes.job_offer.first.created_at.to_date
                total_days += (job_offer_date - shortlisted_date).to_i
              end
            end

            avg = total_days.to_f / filtered_job_applications.successful.count.to_f
          end
    avg
  end

  def average_time_security_clearance
    # Security Clearance Time Frame ( Average time between Request and Receive the Form)
    avg = if filtered_job_applications.security_clearance.count.zero?
            0
          else

            total_days = 0
            filtered_job_applications.security_clearance.each do |job_application|
              send_req_date = job_application.job.created_at.to_date
              receive_form_security_date = job_application.job_application_status_changes.security_clearance.first.created_at.to_date

              total_days += (receive_form_security_date - send_req_date).to_i
            end
            total_days.to_f / filtered_job_applications.security_clearance.count.to_f
          end
    avg
  end

  def monthly
    months = Date::ABBR_MONTHNAMES[1..-1]
    month_job_count = filtered_job_applications.applied.monthly
    [months, months.map{|month| month_job_count[month.upcase] || 0}]
  end



  def yearly
    year_job_count = filtered_job_applications.applied.yearly
    current_year = Date.today.year
    years = [*((current_year - 11) .. current_year)]
    [years, years.map{ |year| year_job_count[year.to_s] || 0 }]
  end


  def quarterly
    quarter_job_count = filtered_job_applications.applied.quarterly
    quarters = [*1..4]
    [quarters, quarters.map{|q| quarter_job_count[q.to_f] || 0}]
  end


  def counter_jobs_applicant_details
    {
        total_job_applicants: filtered_job_applications.count,
        total_non_reviewed_job_applicants: filtered_job_applications.unreviewed.count,
        total_job_applicants_shortlisted: filtered_job_applications.shortlisted.count,
        total_job_applicants_selected: filtered_job_applications.selected.count,
        total_job_applicants_pass_interview: filtered_job_applications.pass_interview.count,
        total_job_applicants_security_clearance: filtered_job_applications.security_clearance.count,
        total_job_applicants_assessment: filtered_job_applications.assessment.count,
        total_job_applicants_job_offer: filtered_job_applications.job_offer.count,
        total_job_applicants_onboarding: filtered_job_applications.onboarding.count,
        total_job_applicants_interviewed: filtered_job_applications.interviewed.count,
        total_job_applicants_shared: filtered_job_applications.shared.count,
        total_job_applicants_successful: filtered_job_applications.successful.count,
        total_job_applicants_unsuccessful: filtered_job_applications.unsuccessful.count


    }
  end

  def job_applications_count
    {
        internal: JobApplication.internal.count,
        external: JobApplication.external.count,
        civilian: JobApplication.civilian.count,
        military: JobApplication.military.count,
        contractual: JobApplication.contractual.count,
        both: JobApplication.both.count
    }

    # {
    #     internal: {
    #         totlal: JobApplication.internal.count,
    #         civilian: JobApplication.internal.civilian.count,
    #         military: JobApplication.internal.military.count
    #     },
    #     external: {
    #         total: JobApplication.external.count,
    #         civilian: JobApplication.external.civilian.count,
    #         military: JobApplication.external.military.count
    #     },
    #     both: {
    #         total: JobApplication.both.count,
    #         civilian: JobApplication.both.civilian.count,
    #         military: JobApplication.both.military.count
    #     }
    # }
  end

  def count_by_recruiter
    res = []
    hash_employer_id = JobApplicationStatusChange.applied.group(:employer_id).count
    hash_employer_id.each{|id, count| res.push({name: User.find_by_id(id).try(:full_name), count: count})}
    res
  end
end
