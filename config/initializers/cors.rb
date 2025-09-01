Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # origins "http://localhost:5173", "https://teu-front.com" -> Mudar para domínio do front depois
    origins "*"
    resource "/api/*",
      headers: :any,
      expose: ["Authorization"],
      methods: [:get, :post, :put, :patch, :delete, :options]
  end
end
