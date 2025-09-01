# config/initializers/devise.rb
Devise.setup do |config|
  require "devise/orm/active_record"
  config.navigational_formats = []

  config.jwt do |jwt|
    jwt.secret = Rails.application.credentials.devise_jwt_secret_key
    jwt.dispatch_requests = [
      ["POST", %r{^/api/v1/users/sign_in$}],
      ["POST", %r{^/api/v1/users$}],
    ]
    jwt.revocation_requests = [
      ["DELETE", %r{^/api/v1/users/sign_out$}],
    ]
    jwt.request_formats = { api_v1_user: [:json] } # <-- mapeamento real
  end
end
