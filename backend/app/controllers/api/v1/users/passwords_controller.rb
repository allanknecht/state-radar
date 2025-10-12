module Api
  module V1
    module Users
      class PasswordsController < ApplicationController
        respond_to :json
        before_action :authenticate_api_v1_user!

        def change_password
          current_user = User.find(current_api_v1_user.id)

          if current_user.update_with_password(change_password_params)
            render json: { message: "Password changed successfully" }, status: :ok
          else
            render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
          end
        end

        private

        def change_password_params
          params.require(:user).permit(:current_password, :password, :password_confirmation)
        end
      end
    end
  end
end
