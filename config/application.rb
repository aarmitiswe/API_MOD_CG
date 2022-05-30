require File.expand_path('../boot', __FILE__)
require 'logger'
require 'rails/all'
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module BloovoApi
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    # config.time_zone = 'Asia/Dubai'
    # config.active_record.default_timezone = :local

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
    # this line to prevent convert empty array to nil
    config.action_dispatch.perform_deep_munge = false

    # don't generate RSpec tests for views and helpers
    config.generators do |g|
      g.test_framework :rspec, fixture: true
      g.fixture_replacement :factory_girl, dir: 'spec/factories'
      g.view_specs false
      g.helper_specs false
      g.stylesheets = false
      g.javascripts = false
      g.helper = false
    end

    config.autoload_paths += Dir["#{config.root}/lib/**/"]


    # config.action_dispatch.default_headers = {
    #   'Access-Control-Allow-Origin' => '*',
    #   'Access-Control-Request-Method' => '*',
    #   'Access-Control-Allow-Headers' => '*'
    # }

    config.middleware.insert_before 0, "Rack::Cors" do
      allow do
        origins '*'
        resource '*', :headers => :any, :methods => [:get, :post, :put, :patch, :delete]
      end
    end

    #   Delayed Jobs
    config.active_job.queue_adapter = :delayed_job
    #   AWS Storage
=begin
    config.paperclip_defaults = {
        storage: :s3,
        s3_region: Rails.application.secrets['AWS_REGION'],
        url: Rails.application.secrets['AWS_URL'],
        s3_credentials: {
            bucket: Rails.application.secrets['AWS_BUCKET'],
            access_key_id: Rails.application.secrets['AWS_ACCESS_KEY_ID'],
            secret_access_key: Rails.application.secrets['AWS_SECRET_ACCESS_KEY']
        },
        s3_protocol: :https
    k
=end
      config.paperclip_defaults = {
        storage: :filesystem,
        url: "#{Rails.application.secrets['BACKEND']}/system/:class/:attachment/:id_partition/:style/:basename_:extension.:extension",
        path: ":rails_root/public/system/:class/:attachment/:id_partition/:style/:basename_:extension.:extension",
        # url: "#{Rails.application.secrets['BACKEND']}/system/:class/:attachment/:id_partition/:style_:filename",
        # path: ':rails_root/public/system/:class/:attachment/:id_partition/:style_:filename',
        # default_url: nil
        # url: "#{Rails.application.secrets['BACKEND']}/system/:class/:attachment/:id_partition/:style.:extension",
        # path: Rails.application.secrets['FOLDER_UPLOAD_PATH']
    }

    config.encoding = "utf-8"

    Paperclip::Attachment.default_options[:default_url] = ""
    # Algolia.init(application_id: Rails.application.secrets['ALGOLIA_APP_ID'], api_key: Rails.application.secrets['ALGOLIA_API_KEY'])

    # This code for path of paperclip
    Paperclip.interpolates :encoded_id do |attachment, style|
      attachment.instance.id.to_s(36)
    end

    Paperclip.interpolates :encoded_created_time do |attachment, style|
      attachment.instance.created_at.to_i.to_s(36)
    end

    config.middleware.use 'RequestLogger'
  end
end

class SpecialLog
  LogFile = Rails.root.join('log', 'mod_custom.log')
  class << self
    cattr_accessor :logger
    delegate :debug, :info, :warn, :error, :fatal, :to => :logger
  end
end

class RequestLogger
  def initialize app
    @app = app
    SpecialLog.logger = Logger.new(SpecialLog::LogFile, 'daily')
    SpecialLog.logger.level = 'fatal'
  end

  def call(env)
    request = ActionDispatch::Request.new env
    started_on = Time.now
    begin

      status, headers, body = response = @app.call(env)
      # status, _, _ = response = @app.call(env)
      # binding.pry

      log(env, body, request, status, started_on, Time.now)
    rescue Exception => exception
      status = determine_status_code_from_exception(exception)
      log(env, body, request, status, started_on, Time.now, exception)
      raise exception
    end

    response
  end

  def log(env, body, request, status, started_on, ended_on, exception = nil)
    url = env['REQUEST_URI']
    path = env['PATH_INFO']
    user = try_current_user(env)
    time_spent = ended_on - started_on
    user_agent = env['HTTP_USER_AGENT']
    ip = env['action_dispatch.remote_ip'].calculate_ip
    request_method = env['REQUEST_METHOD']
    http_host = env['HTTP_HOST']
    response_body = (status == 200) ? body.body : nil

    log = { status: status,
      url: url,
      path: path,
      user_id: user.try(:id),
      params: request.params,
      response_body: response_body,
      time_spent: time_spent,
      user_agent: user_agent,
      ip: ip,
      request_method: request_method,
      http_host: http_host,
      error_type: exception&.class&.name,
      error_message: exception&.message}

    SpecialLog.fatal("\n")
    SpecialLog.fatal('******************************** BLOCK START ***********************************************')
    SpecialLog.fatal("HTTP_HOST: #{http_host}")
    SpecialLog.fatal("URL: #{url}")
    SpecialLog.fatal("PATH: #{path}")
    SpecialLog.fatal("METHOD: #{request_method}")
    SpecialLog.fatal("USER_ID: #{user.try(:id)}")
    SpecialLog.fatal("PARAMS: #{request.params}")
    SpecialLog.fatal("RESPONSE_BODY: #{response_body}")
    SpecialLog.fatal("ERROR_TYPE: #{exception&.class&.name}")
    SpecialLog.fatal("ERROR_MESSAGE: #{exception&.message}")
    SpecialLog.fatal("TIME_SPENT: #{time_spent}")
    SpecialLog.fatal("USER_AGENT: #{user_agent}")
    SpecialLog.fatal("IP: #{ip}")
    # SpecialLog.fatal(log)
    SpecialLog.fatal('******************************** BLOCK END **********************************************')
    SpecialLog.fatal("\n")


  rescue Exception => exception
    Rails.logger.error(exception.message)

  end

  def determine_status_code_from_exception(exception)
    exception_wrapper = ActionDispatch::ExceptionWrapper.new(nil, exception)
    exception_wrapper.status_code
  rescue
    500
  end

  def try_current_user(env)
    controller = env['action_controller.instance']
    return unless controller.respond_to?(:current_user, true)
    return unless [-1, 0].include?(controller.method(:current_user).arity)
    controller.__send__(:current_user)
  end
end
