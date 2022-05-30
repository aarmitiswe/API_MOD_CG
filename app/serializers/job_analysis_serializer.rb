class JobAnalysisSerializer < ActiveModel::Serializer
  include PieChartHelper

  attributes :id,
             :analysis_applications_by_job_education,
             :analysis_applications_by_sector,
             :analysis_applications_by_country,
             :analysis_applications_by_age

  def analysis_applications_by_age
    year_count = object.analysis_applications_by_age
    build_age_slices(year_count)
  end

  # [job_education, sector, country]
  # this metaprogramming to get the hash of field id & the value
  # sample: sectors = {1: 3, 6: 66, ..}  {sector_id: count_applications}
  Job::JOBSEEKER_FIELDS_ANALYSIS.each do |field_name|
    define_method("analysis_applications_by_#{field_name}") do
      language = serialization_options[:ar] ? "ar" : "en"
      field_id_percentage = object.send("analysis_applications_by_#{field_name}", *[language])
      collect_small_values(field_id_percentage)
    end
  end
end