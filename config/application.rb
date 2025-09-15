# config/application.rb
require_relative "boot"
require "rails/all"

Bundler.require(*Rails.groups)

module PiCincoWeb
  class Application < Rails::Application
    config.load_defaults 8.0

    # Timezone: exibe em -03, salva em UTC
    config.time_zone = "America/Sao_Paulo"
    config.active_record.default_timezone = :utc
    config.active_record.time_zone_aware_types = [:datetime, :time]

    # Autoload em lib/ (ignorando subpastas não-Ruby)
    config.autoload_lib(ignore: %w[assets tasks])

    # App somente API
    config.api_only = true
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore, key: "_myapp_session"
  end
end
