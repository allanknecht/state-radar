Rails.application.config.session_store :cookie_store,
  key: "_myapp_session",
  same_site: :none, # ou :lax, dependendo do front
  secure: Rails.env.production?
