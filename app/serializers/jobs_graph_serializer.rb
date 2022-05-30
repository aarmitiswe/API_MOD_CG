class JobsGraphSerializer < ActiveModel::Serializer
  delegate :current_user, to: :scope
  # attributes :monthly, :quarterly, :yearly, :counter_jobs_details, :most_recent_jobs, :all_jobs_analysis_by_posted_date, :jobs_count
  attributes :jobs_count

  attr_accessor :job_application_ids

  def filtered_job_ids
    @job_application_ids ||= current_user.jobs.not_draft.where(company_id: object.id).ransack(serialization_options[:q]).result.map(&:id)
    @job_application_ids
  end

  def monthly
    months = Date::ABBR_MONTHNAMES[1..-1]
    month_job_count = current_user.jobs.not_graduate_program.where(id: filtered_job_ids).monthly
    [months, months.map{|month| month_job_count[month.upcase] || 0}]
  end




  def yearly
    year_job_count = current_user.jobs.not_graduate_program.where(id: filtered_job_ids).yearly
    current_year = Date.today.year
    years = [*((current_year - 11) .. current_year)]
    [years, years.map{ |year| year_job_count[year.to_s] || 0 }]
  end


  def quarterly
    quarter_job_count = current_user.jobs.not_graduate_program.where(id: filtered_job_ids).quarterly
    quarters = [*1..4]
    [quarters, quarters.map{|q| quarter_job_count[q.to_f] || 0}]
  end


  def counter_jobs_details
    {
        total_jobs: current_user.jobs.not_graduate_program.where(id: filtered_job_ids).count,
        active_jobs: current_user.jobs.not_graduate_program.where(id: filtered_job_ids).active.count,
        deleted_jobs: current_user.jobs.not_graduate_program.where(id: filtered_job_ids).deleted.count,
        closed_jobs: current_user.jobs.not_graduate_program.where(id: filtered_job_ids).expired.count
    }
  end

  def most_recent_jobs
      results     = []
      current_user.jobs.not_graduate_program.where(id: filtered_job_ids).order(created_at: :desc).limit(5).each do |selected_job|
       job_hash_object = {
            id: selected_job.id,
            title: selected_job.title,
            views_count: selected_job.views_count,
            applicant_count: selected_job.applicants.count,
            hired: !selected_job.job_applications.successful.blank?,
            count_applicants_grouped_by_matching_percentage_range: selected_job.group_applicants_by_matching_percentage_range([[0,50], [50,70], [70,100]])
       }

       results.push job_hash_object
     end

    return results
  end

  def all_jobs_analysis_by_posted_date
    [
        {min_num_days: 0, max_num_days: 20, jobs_count: object.jobs.where("created_at >= ?", Date.today - 20.days).count},
        {min_num_days: 20, max_num_days: 40, jobs_count: object.jobs.where("created_at >= ? AND created_at < ?", Date.today - 40.days, Date.today - 20.days).count},
        {min_num_days: 40, max_num_days: 1000, jobs_count: object.jobs.where("created_at < ?", Date.today - 40.days).count},
    ]
  end

  def jobs_count
    employer_job_application_status_changes = current_user.employer_job_application_status_changes

    {
        total_count: current_user.jobs.count,
        approved_count: current_user.jobs.approved.count,
        rejected_count: current_user.jobs.rejected.count,
        sent_count: current_user.jobs.sent.count,
        offers_accepted_count: OfferLetter.where(job_application_status_change_id: employer_job_application_status_changes.map(&:id)).get_offer_letter_status_count("approved"),
        offers_rejected_count: OfferLetter.where(job_application_status_change_id: employer_job_application_status_changes.map(&:id)).get_offer_letter_status_count("rejected")
    }
  end


end
