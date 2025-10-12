module Api
  module V1
    module Users
      class SessionsController < ApplicationController
        respond_to :json

        def create
          user = User.find_by(email: params[:user][:email])

          if user && user.valid_password?(params[:user][:password])
            # Usar o Devise JWT para gerar o token
            token = Warden::JWTAuth::UserEncoder.new.call(user, :api_v1_user, nil)

            render json: {
              user: {
                id: user.id,
                email: user.email,
              },
              token: token,
            }, status: :ok
          else
            render json: { error: "Invalid email or password" }, status: :unauthorized
          end
        end

        def destroy
          # Para logout, apenas retornar sucesso
          head :no_content
        end
      end
    end
  end
end
