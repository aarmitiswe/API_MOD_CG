# require 'models/concerns/send_invitation'
require 'tilt/erb'


# TODO: Not used & Not complete
namespace :notifier do
  # CRON JOBS
  #
  desc "send mails for reminder stc"
  task reminder_stc: :environment do

    OfferLetter.where(received_from_stc_at: nil).where("created_at < ?", Date.today).each do |offer_letter|
      User.recruiters_for_job(offer_letter.job).each_with_index do |rec, index|
        template_values = offer_letter.get_feedback_template_values
        template_values[:RecruiterName] = rec[:full_name]

        puts "Send to #{rec[:email]} reminder for receive from STC"

        offer_letter.delay(run_at: (index + 10).seconds.from_now).send_email "reminder_update_jobseeker_offer_letter",
                                                                             [{email: rec[:email], name: rec[:name]}],
                                                                             {
                                                                                 message_body: nil,
                                                                                 message_subject: "تذكير تلقائي لمتابعة حالة العرض الوظيفي مع (STCS) ",
                                                                                 template_values: template_values
                                                                             }
      end
    end

    # reminder to share with candidate
    OfferLetter.where.not(received_from_stc_at: nil).where(sent_to_candidate_at: nil, jobseeker_status: nil).each do |offer_letter|
      User.recruiters_for_job(offer_letter).each_with_index do |rec, index|
        template_values = offer_letter.get_feedback_template_values
        template_values[:RecruiterName] = rec[:full_name]

        puts "Send to #{rec[:email]} reminder for sending to candidate"

        offer_letter.delay(run_at: (index + 10).seconds.from_now).send_email "reminder_send_jobseeker_offer_letter",
                                                                             [{email: rec[:email], name: rec[:name]}],
                                                                              {
                                                                                  message_body: nil,
                                                                                  message_subject: " تذكير تلقائي لمتابعة إرسال العرض للمرشح ",
                                                                                  template_values: template_values
                                                                              }
      end
    end



    OfferLetter.where.not(received_from_stc_at: nil).where.not(sent_to_candidate_at: nil).where("received_from_stc_at < ? AND sent_to_candidate_at < ?", Date.today, Date.today).where(jobseeker_status: nil).each do |offer_letter|
      User.recruiters_for_job(offer_letter).each_with_index do |rec, index|
        template_values = offer_letter.get_feedback_template_values
        template_values[:RecruiterName] = rec[:name]

        puts "Send to #{rec[:email]} reminder for jobseeker status not set yet"

        offer_letter.delay(run_at: (index + 10).seconds.from_now).send_email "reminder_update_status_jobseeker_offer_letter",
                                                                             [{email: rec[:email], name: rec[:name]}],
                                                                             {
                                                                                 message_body: nil,
                                                                                 message_subject: "  تذكير تلقائي لمتابعة الرد على العرض الوظيفي للمرشح ",
                                                                                 template_values: template_values
                                                                             }
      end
    end

    JobApplication.interviewed.each do |job_application|
      if !job_application.is_submitted_by_all_interviewers?
        puts "Fill Evaluation FORM job_application_id: #{job_application.id} AND job_id: #{job_application.job_id}"
        job_application.reminder_submit_evaluation_form
        sleep 1
      end
    end

    # There is condition, send if only on boarding manager approved
    BoardingRequisition.where(user_id: User.onboarding_manager.first.id).approved.each do |boarding_requisition|
      boarding_requisition.boarding_form.send_request_to_recruitment_manager
      sleep 1
    end

    JobApplication.security_clearance.each do |job_application|
      if job_application.job_application_status_changes.assessment.last.try(:interviews).try(:count) == 0 && (job_application.job.grade && ['Level 2', 'Level 3', 'Level 4'].include?(job_application.job.grade.name))
        job_application.suggest_interview_assessment
        sleep 1
      end
    end

    JobApplication.assessment.each do |job_application|
      if job_application.job_application_status_changes.assessment.last.try(:interviews).try(:count) == 0 && (job_application.job.grade && ['Level 2', 'Level 3', 'Level 4'].include?(job_application.job.grade.name))
        job_application.suggest_interview_assessment
        sleep 1
      end
    end

    JobApplication.job_offer.each do |job_application|
      if job_application.job_application_status_changes.assessment.last.try(:interviews).try(:count) == 0 && (job_application.job.grade && ['Level 2', 'Level 3', 'Level 4'].include?(job_application.job.grade.name))
        job_application.suggest_interview_assessment
        sleep 1
      end
    end

    JobApplication.on_boarding.each do |job_application|
      job_application_status_change = job_application.job_application_status_changes.onboarding.where(on_boarding_status: "pre_joining").last

      if job_application_status_change.present? && job_application_status_change.offer_requisitions.count > 0 && job_application_status_change.offer_requisitions.all?{|j| j.is_approved?} && job_application.job_application_status_changes.on_boarding.where(on_boarding_status: "joined").blank?
        job_application_status_change.offer_requisitions.last.send_mail_notification
        sleep 1
      end


      joined = job_application.job_application_status_changes.onboarding.where(on_boarding_status: "joined").last

      if joined.present?
        joined.watheq_check_notification
      end
    end
  end

  desc "send mails for reminder shared candidates"
  task reminder_hiring_manager_shared_candidates: :environment do
    job_ids = JobApplication.shared.where("shared_with_hiring_manager = ? AND created_at < ?", true, Date.today - 5.days).pluck(:job_id) | [-1]
    Job.where(id: job_ids).each do |job|
      job.job_applications.shared.first.reminder_late_shared_candidates
      sleep 1
    end
  end

  desc "send mails for reminder upload document candidates"
  task reminder_upload_document_candidates: :environment do
    JobApplicationStatusChange.where(on_boarding_status: 'beginning').each do |job_application_status_change|
      job_application_status_change.beginning_notification
      sleep 1
    end

    JobApplicationStatusChange.where(on_boarding_status: 'pre_joining').each do |job_application_status_change|
      if job_application_status_change.can_send_prejoin?
        job_application_status_change.pre_join_notification
        sleep 1
      end
    end
  end

  desc 'Send mails for suggested jobs'
  task :send_suggested_jobs_cron_job, :time_units do |t, args|
    time_units = args[:time_units]
    time_units.keys.each do |time_unit_key|
      break if Job.active.where("created_at >= (?)::date", 1.send(time_units[time_unit_key]).ago.beginning_of_day).blank?
      users_jobseekers = User.jobseekers.send("#{time_unit_key}_notify_jobs")

      users_jobseekers.each do |user|
        jobs = Job.suggested_jobs(user.jobseeker, "matching_percentage", {active_eq: true, created_at_gteq: 1.send(time_units[time_unit_key]).ago.beginning_of_day})


        unless jobs.blank?

          template = Tilt::ERBTemplate.new("#{pwd}/app/views/api/v1/notifier/suggested_jobs_responsive.html.erb")
          output = template.render(user, user: user,
                                   jobs: jobs.first(3))

          user.delay.send_email("Suggested Jobs",
                          [{email: user.email, name: user.full_name}],
                          {
                              message_subject: "BLOOVO.COM | Suggested jobs that match your profile",
                              message_body: output
                          })
        end
      end
    end
  end

  desc 'Send mails daily with suggested jobs'
  task send_daily_suggested_jobs_cron_job: :environment do
    Rake::Task['notifier:send_suggested_jobs_cron_job'].execute({time_units: {"daily" => "day"}})
  end

  desc 'Send mails weekly with suggested jobs'
  task send_weekly_suggested_jobs_cron_job: :environment do
    Rake::Task['notifier:send_suggested_jobs_cron_job'].execute({time_units: {"weekly" => "week"}})
  end

  desc 'Send mails monthly with suggested jobs'
  task send_monthly_suggested_jobs_cron_job: :environment do
    Rake::Task['notifier:send_suggested_jobs_cron_job'].execute({time_units: {"monthly" => "month"}})
  end

  desc 'Send mails for applicatns to jobs cron jobs'
  task :send_applicants_cron_job, :time_units do |t, args|
    time_units = args[:time_units]
    time_units.keys.each do |time_unit_key|
      break if JobApplication.where("created_at >= (?)::date", 1.send(time_units[time_unit_key]).ago.beginning_of_day).blank?
      # users in company

      jobs = Job.active.send("#{time_unit_key}_notify_applicants")

      jobs.each do |job|
        next if JobApplication.where("created_at >= (?)::date AND job_id = ?", 1.send(time_units[time_unit_key]).ago.beginning_of_day, job.id).blank?

        job_applications = job.job_applications.where("created_at >= (?)::date", 1.send(time_units[time_unit_key]).ago.beginning_of_day)
        applicants = Jobseeker.where(id: job_applications.map(&:jobseeker_id))
        unless applicants.blank?
          template = Tilt::ERBTemplate.new("#{pwd}/app/views/api/v1/notifier/applicants.html.erb")
          output = template.render(job.company, company: job.company,
                                   job: job,
                                   applicants: applicants.first(3))

          receivers = job.company.users.map{|user| {email: user.email, name: user.full_name}}
          job.company.company_owner.delay.send_email("Applicants for #{job.title}",
                          receivers,
                          {
                              message_subject: "New applicants for the position #{job.title}",
                              message_body: output
                          })
        end
      end
    end
  end

  desc 'Send mails daily with applicants'
  task send_daily_applicants_cron_job: :environment do
    Rake::Task['notifier:send_applicants_cron_job'].execute({time_units: {"daily" => "day"}})
  end

  desc 'Send mails weekly with applicants'
  task send_weekly_applicants_cron_job: :environment do
    Rake::Task['notifier:send_applicants_cron_job'].execute({time_units: {"weekly" => "week"}})
  end

  # TODO: Remove this part .. no monthly notification when create job
  desc 'Send mails monthly with applicants'
  task send_monthly_applicants_cron_job: :environment do
    Rake::Task['notifier:send_applicants_cron_job'].execute({time_units: {"monthly" => "month"}})
  end

  desc 'Send rejection email to rejected candidates for Graduate Program'
  task send_rejection_email_graduate_program_cron_job: :environment do
    template_values = {}
    # All jobseekers having graduate program and not matched and greater or equal to 1 August 2019 and email not sent before
    jobseekers= Jobseeker.where(complete_step: 4, id: JobseekerGraduateProgram.where('created_at >= ? AND  rejection_sent_at IS NULL', '2019-08-01 00:00:00 +0400').not_matched_criteria.pluck(:jobseeker_id))
    jobseekers.each_with_index { |sel_jobseeker, sel_jobseeker_index|
      # Candidate whose account is more than 24 hours
      if ((Time.now.in_time_zone('Abu Dhabi') - sel_jobseeker.created_at.in_time_zone('Abu Dhabi'))/ 1.hour).round >= 24
        template_values = {
            primaryColor: Rails.application.secrets[:ATS_CSS]["colors"]["primary"],
            secondaryColor: Rails.application.secrets[:ATS_CSS]["colors"]["secondary"],
            lightBg: Rails.application.secrets[:ATS_CSS]["colors"]["lightBg"],
            borderColor: Rails.application.secrets[:ATS_CSS]["colors"]["border"],
            WebsiteName: Rails.application.secrets[:ATS_NAME]["website_name"],
            URLRoot: Rails.application.secrets[:BACKEND],
            Website: Rails.application.secrets[:FRONTEND],
            MainLogo: "#{Rails.application.secrets[:BACKEND]}/email_templates/mail-logo.png",
            JobseekerFullName: sel_jobseeker.full_name,
            CompanyName: Rails.application.secrets[:ATS_NAME]["business_name"],
            CreateDate: sel_jobseeker.created_at.strftime("%d %b, %Y"),
            UserId: sel_jobseeker.user.id_6_digits
        }


        sel_jobseeker.user.delay.send_email "reject_in_gp",
                        [{email: sel_jobseeker.email, name: sel_jobseeker.full_name}],
                        {
                            message_body: nil,
                            template_values: template_values
                        }
        sel_jobseeker.jobseeker_graduate_program.update(rejection_sent_at: Time.now)
      end

    }
  end


  desc 'Send mails for blogs cron job'
  task :send_blogs_cron_job, :time_units do |t, args|
    time_units = args[:time_units]
    time_units.keys.each do |time_unit_key|
      break if Blog.active.where("created_at >= (?)::date", 1.send(time_units[time_unit_key]).ago).blank?

      receivers = User.send("#{time_unit_key}_notify_blogs").map{|u| {email: u.email, name: u.full_name}}


      blogs = Blog.active.where("created_at >= (?)::date", 1.send(time_units[time_unit_key]).ago)
      unless blogs.blank?

        user = User.find_by_email('myakout@bloovo.com')

        template = Tilt::ERBTemplate.new("#{pwd}/app/views/api/v1/notifier/blogs.html.erb")
        output = template.render(user, blogs: blogs.first(3))

        user.delay.send_email("New Blogs",
                        receivers,
                        {
                            message_subject: "#{blogs.first.title}",
                            message_body: output
                        })
      end

    end
  end

  desc 'Send mails daily with blogs'
  task send_daily_blogs_cron_job: :environment do
    Rake::Task['notifier:send_blogs_cron_job'].execute({time_units: {"daily" => "day"}})
  end

  desc 'Send mails weekly with blogs'
  task send_weekly_blogs_cron_job: :environment do
    Rake::Task['notifier:send_blogs_cron_job'].execute({time_units: {"weekly" => "week"}})
  end

  desc 'Send mails monthly with blogs'
  task send_monthly_blogs_cron_job: :environment do
    Rake::Task['notifier:send_blogs_cron_job'].execute({time_units: {"monthly" => "month"}})
  end


  desc 'Send mails for poll quesrtion cron job'
  task :send_poll_question_cron_job, :time_units do |t, args|
    time_units = args[:time_units]
    time_units.keys.each do |time_unit_key|
      break if PollQuestion.active.where("created_at >= ?", 1.send(time_units[time_unit_key]).ago).blank?

      User.send("#{time_unit_key}_notify_polls").each do |user|
        for_user = user.is_jobseeker? ? "for_jobseeker" : "for_employer"
        poll_question = PollQuestion.active.where("created_at >= (?)::date", 1.send(time_units[time_unit_key]).ago).send(for_user).first

        unless poll_question.blank?

          template = Tilt::ERBTemplate.new("#{pwd}/app/views/api/v1/notifier/poll_questions.html.erb")
          output = template.render(user, user: user,
                                   poll_question: poll_question)

          puts output
          # user.send_email("New PollQuestions",
          #                 [{email: user.email, name: user.full_name}],
          #                 {
          #                     message_subject: "New Poll Question",
          #                     message_body: output
          #                 })
        end
      end
    end
  end

  desc 'Send mails daily with poll_question'
  task send_daily_poll_question_cron_job: :environment do
    Rake::Task['notifier:send_poll_question_cron_job'].execute({time_units: {"daily" => "day"}})
  end

  desc 'Send mails weekly with poll_question'
  task send_weekly_poll_question_cron_job: :environment do
    Rake::Task['notifier:send_poll_question_cron_job'].execute({time_units: {"weekly" => "week"}})
  end

  desc 'Send mails monthly with poll_question'
  task send_monthly_poll_question_cron_job: :environment do
    Rake::Task['notifier:send_poll_question_cron_job'].execute({time_units: {"monthly" => "month"}})
  end


  desc 'Send mails for reminder jobseeker to complete profiles cron job'
  task :send_complete_profile_cron_job, :time_units do |t, args|
    time_units = args[:time_units]
    time_units.keys.each do |time_unit_key|
      old_jobseekers_non_complete = Jobseeker.active_non_complete.where("jobseekers.created_at >= (?)::date", 1.send(time_units[time_unit_key]).ago)
      break if old_jobseekers_non_complete.blank?

      old_jobseekers_non_complete.each do |jobseeker|

        template = Tilt::ERBTemplate.new("#{pwd}/app/views/api/v1/notifier/complete_profile.html.erb")
        output = template.render(jobseeker.user, jobseeker: jobseeker)

        jobseeker.user.delay.send_email("Complete Profile",
                        [{email: jobseeker.user.email, name: jobseeker.user.full_name}],
                        {
                            message_subject: "Your Profile is Not Complete - Hundreds of Jobs are Waiting for You!",
                            message_body: output
                        })
      end
    end
  end

  desc 'Send mails daily for complete profile'
  task send_complete_profile_daily_cron_job: :environment do
    Rake::Task['notifier:send_complete_profile_cron_job'].execute({time_units: {"daily" => "day"}})
  end


  desc 'Send mails for reminder jobseeker to complete profiles cron job'
  task :send_confirmed_account_cron_job, :time_units do |t, args|
    time_units = args[:time_units]
    time_units.keys.each do |time_unit_key|
      non_confiremed_users = User.jobseekers.where("users.confirmed_at IS NULL AND users.created_at > (?)::date", 7.send(time_units[time_unit_key]).ago)

      break if non_confiremed_users.blank?

      non_confiremed_users.each do |user|
        user.delay.resend_confirmation_instructions
      end
    end
  end

  desc 'Send mails daily for complete profile'
  task send_confirmed_account_daily_cron_job: :environment do
    Rake::Task['notifier:send_confirmed_account_cron_job'].execute({time_units: {"daily" => "day"}})
  end



  desc "Graduate Program Move Unsuccessful to Shortlisted "
  task gp_move_unsuccessful_shortlisted_send_email: :environment do
    user_emails = ["a.m.221333@gmail.com"]
    User.where(email: user_emails).each do |sel_user|
      if sel_job_application = Job.find_by_title('graduate_program').job_applications.where(jobseeker_id: sel_user.jobseeker.id).last
        # Checking if selected candidate is already unsuccessful before
        if JobApplicationStatusChange.where(jobseeker_id: sel_user.id, job_application_id: sel_job_application.id, job_application_status_id: JobApplicationStatus.find_by_status("Unsuccessful").id).count > 0
          # Destroying unsuccessful status change
          JobApplicationStatusChange.where(jobseeker_id: sel_user.id, job_application_id: sel_job_application.id, job_application_status_id: JobApplicationStatus.find_by_status("Unsuccessful").id).last.destroy
          # Moving selected Candidate to shortlisted
          if JobApplicationStatusChange.create({jobseeker_id: sel_user.id,
                                                job_application_status_id: JobApplicationStatus.find_by_status("Shortlisted").id,
                                                job_application_id: sel_job_application.id,
                                                employer_id: User.find_by_role('company_owner').id,
                                                comment: "Candidate Shortlisted",
                                                notify_jobseeker: false
                                               })
            puts "Sending Shortlisted Email to #{sel_user.email}"
            # if shortlist was successful send email to candidate
            vars = [{name: "created_date", content: Date.today.strftime("%d %B, %Y") }]
            subject = "NEOM GrOW Shortlisted Candidates"
            email_to = [{email: sel_user.email, name: sel_user.full_name}]
            email_from = Rails.application.secrets['SENDER_EMAIL']
            sel_user.send_email_template "shortlisted", vars, email_to, email_from, subject
          end

        end
      end

    end
    puts "Done"
  end



  desc "Graduate Program Move to Shortlisted and Send Email to candidates"
  task gp_move_shortlisted_unsuccessful_send_email: :environment do

    # List of Candidate Ids to be moved to shortlisted
    candidate_list = [18585,36020,44006,20694,15303,24597,55136,24359,17706,27687,40631,11296,54110,37234,52212,46725,18586,16904,18682,3987,1517,45964,41159,37757,31036,22972,28760,21230,39361,37616,54665,44043,34865,22741,37460,282,13699,18167,46006,49882,42199,22972,21585,38028,24695,51764,19192,23584,18254,5711,39018,9436,12557,29459,34958,2859,7984,10995,23696,42983,26387,27838,45908,51035,4851,14120,30484,35780,42009,55650,20817,20963,37217,50651,45031,5327,36465,48047,8875,32134,8581,16606,21918,40664,34973,11925,21630,10769,23065,27167,27614,39034,51407,34142,47868,19706,14717,28738,54423,33409,36496,9406,30253,37272,1778,33617,26839,3842,22562,35253,48734,49001,53911,3791,51080,14463,26519,37008,39424,49922,1433,16408,49285,39977,55542,21181,31981,5597,3395,23910,39801,18290,40802,26697,36087,36326,37947,38097,48449,49658,52702,32557,48510,47502,47039,31130,31764,15184,38342,21279,25753,46597,49705,54725,52715,24692,33180,7930,39714,24574,40724,5284,24011,24699,24817,42655,44884,51888,17415,4698,6398,17869,23208,24723,41172,46083,50137,28626,29826,30975,37605,9505,21105,35852,14502,6722,17134,53427,37848,33632,48004,9898,35326,16284,45417,39661,54186,6703,40466,315,919,2692,5643,8300,8371,8498,40734,26232,21195,25135,25525,26895,32160,37691,5466,44349,45892,52910,5115,23148,33853,7034,35876,21070,20087,13255,19346,54534,46772,20924,11964,2318,38614,17587,31230,37197,43380,45680,39067,32407,46824,10304,26890,27105,17350,6554,27777,38459,42233,4803,5816,18915,13833,11644,11929,31264,39765,47598,55543,41031,18462,19634,35496,9712,12361,47377,21413,45943,54713,9646,38619,24292,20288,14644,36735,41082,43286,16916,33557,5218,19759,54468,42095,51051,48695,24131,44638,22750,45879,46044,51768,23746,46173,33048,25216,8180,1593,16406,18526,9498,11971,23432,39951,41127,43043,39304,50308,52443,13661,7438,9969,25661,42894,20395,20189,55767,30508,21471,26512,2884,27786,7174,24243,37723,52824,55052,25219,19501,18848,41491,46819,54715,3666,4421,20836,8362,24173,20425,19806,4703,6064,46930,14294,16275,28463,7810,10537,17328,28581,43214]
    # candidate_list = [71336, 71332]

    # Looping through all candidate applications for Graduate Program Job that match criteria
    Job.find_by_title('graduate_program').job_applications.where(jobseeker_id: JobseekerGraduateProgram.matched_criteria.pluck(:jobseeker_id)).each do |sel_job_application|
      sel_user = sel_job_application.jobseeker.user
      puts "selected uses email #{sel_user.email}"
      # Checking  selected candidate in  the Shortlist Candidate Ids List
      if candidate_list.include?(sel_user.id)
        # Checking if selected candidate is already shortlisted before
        if JobApplicationStatusChange.where(jobseeker_id: sel_user.id, job_application_id: sel_job_application.id, job_application_status_id: JobApplicationStatus.find_by_status("Shortlisted").id).count == 0
          # Moving selected Candidate to shortlisted
           if JobApplicationStatusChange.create({jobseeker_id: sel_user.id,
                                             job_application_status_id: JobApplicationStatus.find_by_status("Shortlisted").id,
                                             job_application_id: sel_job_application.id,
                                             employer_id: User.find_by_role('company_owner').id,
                                             comment: "Candidate Shortlisted",
                                             notify_jobseeker: false
                                            })
             puts "Sending Shortlisted Email to #{sel_user.email}"
             # if shortlist was successful send email to candidate
             vars = [{name: "created_date", content: Date.today.strftime("%d %B, %Y") }]
             subject = "NEOM GrOW Shortlisted Candidates"
             email_to = [{email: sel_user.email, name: sel_user.full_name}]
             email_from = Rails.application.secrets['SENDER_EMAIL']
             sel_user.send_email_template "shortlisted", vars, email_to, email_from, subject
           end

        end
      else
        # Reach here if candidate is not in the Shortlisted candidate list
        # Checking if candidate has already been moved to Unsuccessful
        if JobApplicationStatusChange.where(jobseeker_id: sel_user.id, job_application_id: sel_job_application.id, job_application_status_id: JobApplicationStatus.find_by_status("Unsuccessful").id).count == 0
          # Moving Candidate to unsuccessful
          if JobApplicationStatusChange.create({jobseeker_id: sel_user.id,
                                             job_application_status_id: JobApplicationStatus.find_by_status("Unsuccessful").id,
                                             employer_id: User.find_by_role('company_owner').id,
                                             job_application_id: sel_job_application.id,
                                             comment: "Candidate Unsuccessful",
                                             notify_jobseeker: false
                                            })
            puts "Sending Unsuccessful Email to #{sel_user.email}"
            # if candidate was made unsuccessful send email to candidate
            vars = [{name: "created_date", content: Date.today.strftime("%d %B, %Y") }]
            subject = "NEOM GrOW Unsuccessful Candidates"
            email_to = [{email: sel_user.email, name: sel_user.full_name}]
            email_from = Rails.application.secrets['SENDER_EMAIL']
            sel_user.send_email_template "unsuccessful", vars, email_to, email_from, subject

            end
        end
      end
    end
    puts "Done"
  end

end
