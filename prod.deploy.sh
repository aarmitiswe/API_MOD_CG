RAILS_ENV=production rake db:migrate
RAILS_ENV=production rake updater_email_templates:create_templates_for_mod
RAILS_ENV=production rake updater_email_templates:create_templates_for_assessment
RAILS_ENV=production rake updater_email_templates:create_templates_for_interview_requisition

sudo service nginx restart

RAILS_ENV=production bin/delayed_job -n 5 restart

whenever --update-crontab

sudo service cron restart