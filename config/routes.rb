Rails.application.routes.draw do
  # (opcional) rotas não-API:

  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api, defaults: { format: :json } do
    get "health/index"

    namespace :v1 do
      resources :scraper_records, only: %i[index show]
      devise_for :users,
        path: "",
        path_names: { sign_in: "users/sign_in", sign_out: "users/sign_out" },
        controllers: {
          sessions: "api/v1/users/sessions",
          registrations: "api/v1/users/registrations",
        }

      resources :properties, only: [:index, :show]
    end
  end
end
