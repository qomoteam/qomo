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

    config.action_mailer.smtp_settings = config_for(:email)['smtp_settings'].symbolize_keys
    config.action_mailer.default_url_options = config_for(:email)['default_url_options'].symbolize_keys

    config.action_cable.allowed_request_origins = [/.*/]
    config.action_cable.disable_request_forgery_protection = true
    config.action_view.field_error_proc = Proc.new { |html_tag, instance|
      if html_tag =~ /<(input|label|textarea|select)/
        html_field = Nokogiri::HTML::DocumentFragment.parse(html_tag)
        html_field.children.add_class 'error'
        html_field.to_s
      else
        html_tag
      end
    }
    config.cache_store = :redis_store, "#{Config.redis}/cache"

  end
end
