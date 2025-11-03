Rails.application.routes.draw do
  # (opcional) rotas não-API:

  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api, defaults: { format: :json } do
    get "health/index"

    namespace :v1 do
      resources :scraper_records, only: %i[index show] do
        collection do
          get :sites
          get :categories
        end
      end

      resources :favorites, only: %i[index create destroy]

      devise_for :users,
                 path: "users",
                 defaults: { format: :json },
                 controllers: {
                   sessions: "api/v1/users/sessions",
                   registrations: "api/v1/users/registrations",
                 },
                 skip: [:passwords]

      # Rota para alterar senha do usuário logado
      patch "users/password/change", to: "users/passwords#change_password"
    end
  end
end
