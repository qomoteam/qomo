# Be sure to restart your server when you modify this file.

Rails.application.config.session_store :redis_store, servers: "#{Config.redis}/session", expires_in: 3.hours
