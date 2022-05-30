class CompanyAnalyticsSerializer < ActiveModel::Serializer
  delegate :current_user, to: :scope

  attributes :id,
             :active_job_count,
             :job_analytics,
             :benefits,
             :monthly_jobs_posted


  def benefits
    self.object.benefits.where("jobs.job_status_id != (?)", 1).uniq
  end

  def active_job_count
    self.object.jobs.active.count
  end


  def monthly_jobs_posted
    months = Date::ABBR_MONTHNAMES[1..-1]
    month_job_count = self.object.jobs.not_draft.monthly
    [months, months.map{|month| month_job_count[month.upcase] || 0}]
  end


  def job_analytics
    self.object.jobs.active.not_draft.order(created_at: :desc).limit(10).map do |selected_job|
      {
          id: selected_job.id,
          title: selected_job.title,
          views_count: selected_job.views_count,
          applicant_count: selected_job.applicants.count,
          salary: selected_job.get_average_salary,
          created_at: selected_job.created_at,
          sector: selected_job.sector,
          similar_job_salary: selected_job.similar_jobs.sum(&:get_average_salary)
      }
    end
  end


end
