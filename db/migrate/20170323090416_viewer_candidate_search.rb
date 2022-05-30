class ViewerCandidateSearch < ActiveRecord::Migration
  def up
    execute <<-SQL
      create view jobseeker_content as select distinct
      jobseekers.id,
      lower(concat_ws(
          ' ',
          users.first_name,
          users.last_name,
          users.email,
          jobseekers.summary,
          skills.name,
          jobseeker_experiences.position,
          jobseeker_experiences.description,
          jobseeker_experiences.company_name)) as keywords
      from jobseekers
      LEFT OUTER join users on users.id = jobseekers.user_id
      LEFT OUTER join jobseeker_skills on jobseeker_skills.jobseeker_id = jobseekers.id
      LEFT OUTER join skills on skills.id = jobseeker_skills.skill_id
      LEFT OUTER join jobseeker_experiences on jobseeker_experiences.jobseeker_id = jobseekers.id;
    SQL
  end

  def down
    execute "DROP VIEW jobseeker_content";
  end
end
