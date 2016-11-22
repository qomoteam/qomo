require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Qomo
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    require File.expand_path('../../app/models/config.rb', __FILE__)

    config.relative_url_root = Config.relative_root
    config.action_cable.url = File.join Config.relative_root, 'cable'

    config.action_mailer.smtp_settings = config_for(:email)['smtp_settings'].symbolize_keys
    config.action_mailer.default_url_options = config_for(:email)['default_url_options'].symbolize_keys

    config.action_cable.allowed_request_origins = [/.*/]
    config.action_cable.disable_request_forgery_protection = true
    config.cache_store = :redis_store, "#{Config.redis}/cache"

    config.to_prepare do
      Devise::RegistrationsController.layout 'security'
      Devise::SessionsController.layout 'security'
      Devise::ConfirmationsController.layout 'security'
      Devise::UnlocksController.layout 'security'
      Devise::PasswordsController.layout 'security'
    end

  end
end
