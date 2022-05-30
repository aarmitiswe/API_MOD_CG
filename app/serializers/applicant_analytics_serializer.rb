class ApplicantAnalyticsSerializer < ActiveModel::Serializer
  include PieChartHelper

  attributes :id,
             :analysis_applications_by_job_education,
             :analysis_applications_by_sector,
             :analysis_applications_by_country,
             :analysis_applications_by_age,
             :analysis_applications_by_nationality,
             :analysis_applications_by_gender,
             :total_applicants

  def analysis_applications_by_age

    if serialization_options[:gp]
      year_count = object.analysis_applications_by_age_gp
    # Note: applied_jobseeker_ids are passed only if requisition is active
    elsif serialization_options[:applied_jobseeker_ids]
        year_count = object.analysis_applications_req_by_age(serialization_options[:applied_jobseeker_ids])
    else
      year_count = object.analysis_applications_by_age
    end
    build_age_slices(year_count)
  end

  def total_applicants
    if  serialization_options[:gp]
      object.applicants.matched_criteria_graduate_program.count
    # Note: applied_jobseeker_ids are passed only if requisition is active
    elsif serialization_options[:applied_jobseeker_ids]
      object.applicants.where(id: serialization_options[:applied_jobseeker_ids]).count
    else
      object.applicants.count
    end
  end

  Job::JOBSEEKER_FIELDS_ANALYSIS.each do |field_name|
    define_method("analysis_applications_by_#{field_name}") do
      #ToDo: graduate program need to fix quick fix for merge
      field_id_percentage = object.send("analysis_applications_by_#{field_name}",
                                        serialization_options[:ar] ? 'ar' : 'en',
                                        serialization_options[:applied_jobseeker_ids],
                                        serialization_options[:gp])
      # field_id_percentage = object.send("analysis_applications_by_#{field_name}",
      #                                   serialization_options[:ar] ? 'ar' : 'en', serialization_options[:applied_jobseeker_ids])
      collect_small_values(field_id_percentage)
    end
  end
end