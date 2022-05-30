namespace :survey do


  desc "Job Seeker Survey"
  task jobseekers_survey: :environment do

    current_page_jobseeker = 1
    total_jobseekers = User.active.jobseekers.paginate(page: current_page_jobseeker, per_page: 1000)
    total_pages_jobseeker = total_jobseekers.total_pages


    subject = "BLOOVO.COM | Job Search Dynamics Survey"
    email_from = Rails.application.secrets['SENDER_EMAIL']


    while current_page_jobseeker <= total_pages_jobseeker && total_jobseekers.size > 0 do

      jobseekers_emails = total_jobseekers.map{|u| {email: u.email, name: u.full_name}}

      u = User.find_by_email(Rails.application.secrets['EMAIL_BLOOVO_ACCOUNT'])
      u.delay.send_email_template "survey", [], jobseekers_emails, email_from , subject

      current_page_jobseeker += 1
      total_jobseekers = User.active.jobseekers.paginate(page: current_page_jobseeker, per_page: 1000)
    end

    puts 'Job Seeker Survey Sent'
  end
end