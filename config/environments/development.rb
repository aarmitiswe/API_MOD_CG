Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # MailCatcher config
  # config.action_mailer.delivery_method = :smtp
  # config.action_mailer.smtp_settings = { :address => 'api.bloovo.io', :port => 1025 }
  # config.action_mailer.default_url_options = { :host => 'api.bloovo.io', :port => 8080 }
  # config.action_mailer.default_url_options[:only_path] = false
  # config.action_mailer.asset_host = 'http://yakout.bloovo.com:3001'

  config.action_mailer.smtp_settings = {
      address: Rails.application.secrets['SENDER_EMAIL_SMTP'],
      port: Rails.application.secrets['SENDER_EMAIL_PORT'],
      domain: Rails.application.secrets['DOMAIN'],
      user_name: Rails.application.secrets['SENDER_EMAIL'],
      password: Rails.application.secrets['SENDER_EMAIL_PASSWORD'],
      authentication: "login",
      enable_starttls_auto: true
  }

  config.action_mailer.default_url_options = { host: Rails.application.secrets['BACKEND']}
  Rails.application.routes.default_url_options[:host] = Rails.application.secrets['BACKEND']

  # config.action_mailer.smtp_settings = {
  #     address: "smtp.mandrillapp.com",
  #     authentication: :plain,
  #     domain: "yakout.bloovo.com:3001",
  #     enable_starttls_auto: true,
  #     password: Rails.application.secrets['mandrill_key'],
  #     port: "587",
  #     user_name: Rails.application.secrets['SENDER_EMAIL']
  # }
  # config.action_mailer.default_url_options = { host: "yakout.bloovo.com:3001"}
end
