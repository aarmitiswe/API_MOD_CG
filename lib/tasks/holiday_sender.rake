require 'tilt/erb'
require "roo"

namespace :holiday_sender do
  desc 'New Year Holiday Jobseekers'
  task new_year_jobseeker: :environment do
    bloovo_owner = User.find_by_email(Rails.application.secrets['EMAIL_BLOOVO_ACCOUNT'])

    current_page_jobseeker = 1
    active_jobseekers = User.active.jobseekers.paginate(page: current_page_jobseeker, per_page: 1000)
    total_pages_jobseeker = active_jobseekers.total_pages

    while current_page_jobseeker <= total_pages_jobseeker && active_jobseekers.size > 0 do

      active_jobseekers_emails = active_jobseekers.map{|u| {email: u.email, name: u.full_name}}
      template = Tilt::ERBTemplate.new("#{pwd}/app/views/holiday_templates/new_year.html.erb")
      output = template.render

      puts "Group Jobseeker #{current_page_jobseeker}"
      puts active_jobseekers_emails.first
      bloovo_owner.delay.send_email("Happy New Year",
                                    active_jobseekers_emails,
                                    {
                                        message_subject: "BLOOVO.COM | Happy New Year",
                                        message_body: output
                                    })

      current_page_jobseeker += 1
      active_jobseekers = User.active.jobseekers.paginate(page: current_page_jobseeker, per_page: 1000)
    end
  end


  desc 'New Year Holiday Employers'
  task new_year_employer: :environment do
    bloovo_owner = User.find_by_email(Rails.application.secrets['EMAIL_BLOOVO_ACCOUNT'])

    current_page_employer = 1
    active_employers = User.active.employers.paginate(page: current_page_employer, per_page: 1000)
    total_pages_employer = active_employers.total_pages

    while current_page_employer <= total_pages_employer && active_employers.size > 0 do

      active_employers_emails = active_employers.map{|u| {email: u.email, name: u.full_name}}
      template = Tilt::ERBTemplate.new("#{pwd}/app/views/holiday_templates/new_year.html.erb")
      output = template.render

      puts "Group Employer #{current_page_employer}"
      puts active_employers_emails.first
      bloovo_owner.delay.send_email("Happy New Year",
                                    active_employers_emails,
                                    {
                                        message_subject: "BLOOVO.COM | Happy New Year",
                                        message_body: output
                                    })

      current_page_employer += 1
      active_employers = User.active.employers.paginate(page: current_page_employer, per_page: 1000)
    end
  end

  desc 'Happy Ramadan'
  task happy_ramadan: :environment do
    bloovo_mailer = BloovoMailer.new

    user_list = User.paginate(page: 1)

    (1..user_list.total_pages).each do |page_num|
      receivers = User.paginate(page: page_num).map{|u| {email: u.email, name: u.full_name}}

      bloovo_mailer.send_holidays_mails "happy_ramdan_2018", receivers, "Ramadan Kareem | BLOOVO.COM"

      puts "============ Done Page # #{page_num} ================="
    end
  end

  desc "Send to Employers"
  task sender_magazine_to_employers: :environment do

    bloovo_mailer = BloovoMailer.new

    user_list = User.employers.paginate(page: 1)

    (1..user_list.total_pages).each do |page_num|
      receivers = User.employers.paginate(page: page_num).map{|u| {email: u.email, name: u.full_name}}

      bloovo_mailer.send_mails_with_vars "magazine", [], receivers, "Download Now: BLOOVO INSIGHTS - Q1, 2019"

      puts "============ Done Page # #{page_num} ================="
    end
  end

  desc "Send to MedGulf Users"
  task send_job_opportunity_medgulf_jobseekers: :environment do
    bloovo_mailer = BloovoMailer.new


    xlsx = Roo::Spreadsheet.open('medgulf.xlsx')
    puts xlsx.info
    medgulf_users_sheet = xlsx.sheet(0)

    (1..medgulf_users_sheet.last_row).each do |col_num|
      user_name = medgulf_users_sheet.cell('B', col_num)
      user_email = medgulf_users_sheet.cell('C', col_num)
      puts "#{user_name}: #{user_email}"
      bloovo_mailer.send_mails_with_vars "medgulf_apply_for_job", [],
                                         [{name: user_name, email: user_email}],
                                         "وظيفة شاغرة - مدير حسابات - شركة ميدقلف"
    end
    puts "Done"
  end

  desc "Send To Employers Insights 2019"
  task send_insights_to_emails: :environment do
    bloovo_mailer = BloovoMailer.new



    # bloovo_mailer.send_mails_with_vars "bloovo_insignts_q2_2019", [],
    #                                    [{name: "BLOOVO Friend", email: "myakout@bloovo.com"}],
    #                                    "BLOOVO Insights Q2-2019 - Latest Trends in HR"

    xlsx = Roo::Spreadsheet.open('Emailer.xlsx')
    puts xlsx.info
    emails_sheet = xlsx.sheet(0)
    puts "Last Row: #{emails_sheet.last_row}"
    (0..emails_sheet.last_row).each do |row_num|
      user_email = emails_sheet.cell('A', row_num)

      bloovo_mailer.send_mails_with_vars "bloovo_insignts_q2_2019", [],
                                         [{name: "BLOOVO Friend", email: user_email}],
                                         "BLOOVO Insights Q2-2019 - Latest Trends in HR"

      puts "Done #{row_num / 100.0}" if row_num % 100.0 == 0
    end
  end

  desc "Dental Ads"
  task dental_ads: :environment do
    bloovo_mailer = BloovoMailer.new

    country_names = ["Egypt", "Lebanon", "United States", "United Kingdom", "Palestine", "Tunisia", "Morocco",
                    "Australia", "New Zealand", "Germany", "France"]

    current_cities = City.where(name: "Dubai")

    nationalities = Country.where(name: country_names)

    target_users = User.jobseekers_in_selected_cities_with_specific_nationalities(current_cities, nationalities)
    per_page = 100
    users_in_page = target_users.paginate(page: 1, per_page: per_page)
    # users = User.where(email: "myakout@bloovo.com").paginate(page: 1)

    (1..users_in_page.total_pages).each do |page_num|
      receivers = target_users.paginate(page: page_num, per_page: per_page).map{|u| {email: u.email, name: u.full_name}}
      # receivers = users.map{|u| {email: u.email, name: u.full_name}}

      bloovo_mailer.send_holidays_mails_as_annoncer "dental_studio", receivers, "Why a Brighter Smile Can Land You Your Dream Job"

      puts "============ Done Page # #{page_num} ================="
    end
  end

  desc "Invoke Delayed Job Manually"
  task invoke_delayed_jobs: :environment do
    Delayed::Job.first(100).each do |job|
      job.invoke_job
      job.destroy
    end
  end
end
