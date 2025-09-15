module Api
  module V1
    module Users
      class SessionsController < Devise::SessionsController
        respond_to :json

        private

        def respond_with(resource, _opts = {})
          render json: { user: { id: resource.id, email: resource.email } }, status: :ok
        end

        def respond_to_on_destroy
          # Para JTIMatcher, um sign_out válido invalida o token (rota DELETE /sign_out)
          head :no_content
        end
      end
    end
  end
end
