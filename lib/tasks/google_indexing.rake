require 'google/apis/indexing_v3'
require 'signet/oauth_2/client'
require 'json'

namespace :google_indexing do

  desc 'Index Jobs to Google'
  task :publish_jobs, [:page_num] => [:environment] do |t, args|
    fd = IO.sysopen("integration/#{Rails.application.secrets['GOOGLE_FILE_PATH']}", "r")
    json_key_io = IO.new(fd,"r")
    # Create instance ServiceAccountCredentials
    client = Google::Auth::ServiceAccountCredentials.make_creds({scope: ['https://www.googleapis.com/auth/indexing'], json_key_io: json_key_io})

    Google::Apis::RequestOptions.default.authorization = client

    # API indexing
    Indexing = Google::Apis::IndexingV3
    service = Indexing::IndexingService.new

    page_num = args[:page_num].to_i
    puts "Start in page #{page_num}"
    jobs = Job.active.where(is_goolge_published: false).order(created_at: :desc).paginate(page: page_num, per_page: 100)
    published_job_ids = []

    jobs.each do |job|
      url_notification_object = Google::Apis::IndexingV3::UrlNotification.new
      url_notification_object.url = "#{Rails.application.secrets['FRONTEND']}/#{job.frontend_path}"
      url_notification_object.type = "URL_UPDATED"

      # Send Request
      response = service.publish_url_notification(url_notification_object)
      if response.class == Google::Apis::IndexingV3::PublishUrlNotificationResponse
        puts "Done #{url_notification_object.url}"
        published_job_ids << job.id
      else
        puts "Not Push #{job.id}"
      end
    end

    Job.where(id: published_job_ids).update_all(is_goolge_published: true)

    puts "Page Num #{page_num} is Done"
    # service.delay(run_at: 5.minutes.from_now, queue: 'indexing_google').publish_url_notification(url_notification_object)
  end

  desc 'Send Jobs to Google using batches'
  task :publish_batch_jobs, [:page_num] => [:environment] do |t, args|
    fd = IO.sysopen("integration/#{Rails.application.secrets['GOOGLE_FILE_PATH']}", "r")
    json_key_io = IO.new(fd,"r")
    # Create instance ServiceAccountCredentials
    client = Google::Auth::ServiceAccountCredentials.make_creds({scope: ['https://www.googleapis.com/auth/indexing'], json_key_io: json_key_io})

    Google::Apis::RequestOptions.default.authorization = client
    method = :post

    page_num = args[:page_num].to_i
    puts "Start in page #{page_num}"
    # jobs = Job.active.paginate(page: page_num, per_page: 100)

    batch_command = Google::Apis::Core::BatchCommand.new(method, "https://indexing.googleapis.com/batch")

    job = Job.active.last
    body_json = {url: "#{Rails.application.secrets['FRONTEND']}/#{job.frontend_path}", type: "URL_UPDATED"}
    body = body_json.to_json

    http_command = Google::Apis::Core::HttpCommand.new(method, "https://indexing.googleapis.com/batch")
    http_command.body = body
    http_command.header = {"Content-Type": "application/json"}

    batch_command.add http_command

    # jobs.each do |job|
    #   body_json = {url: "#{Rails.application.secrets['FRONTEND']}/#{job.frontend_path}", type: "URL_UPDATED"}
    #   body = body_json.to_json
    #
    #   batch_command = batch_command.add Google::Apis::Core::HttpCommand.new(method, "#{Rails.application.secrets['FRONTEND']}/#{job.frontend_path}", body)
    # end

    puts "excute"
    response = batch_command.execute(client.client)
    puts response
  end
end