# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

# TODO: Not used & Not complete
set :output, "/home/mod/clients/mod/API/log/cron_log.log"

# Daily Notification
every 1.day, at: '10:00am', by_timezone: 'Asian/Dubai' do

   rake "notifier:reminder_stc"
   rake "notifier:reminder_hiring_manager_shared_candidates"
   rake "notifier:reminder_upload_document_candidates"
   rake "backup:db"
   # rake "notifier:send_daily_applicants_cron_job"

   # rake "notifier:send_confirmed_account_daily_cron_job"
   # rake "notifier:send_rejection_email_graduate_program_cron_job"
   # rake "notifier:send_complete_profile_daily_cron_job"

   # rake "json_generator:write_countries_with_count_jobs_general"
   # rake "json_generator:write_sectors_with_count_jobs_general"
   # rake "json_generator:write_cities_with_count_jobs_general"
end

every 1.minute do
  rake "sender:sending_mails_custom"
end

# Weekly Notification
every :sunday, at: '10:00am', by_timezone: 'Asian/Dubai' do
   # rake "notifier:send_weekly_applicants_cron_job"
end
