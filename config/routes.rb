Rails.application.routes.draw do
  # (opcional) rotas não-API:

  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api, defaults: { format: :json } do
    get "health/index"

    namespace :v1 do
      resources :scraper_records, only: %i[index show]

      resources :properties, only: [:index, :show]

      devise_for :users,
                 path: "users",
                 defaults: { format: :json },
                 controllers: {
                   sessions: "api/v1/users/sessions",
                   registrations: "api/v1/users/registrations",
                 }
    end
  end
end
