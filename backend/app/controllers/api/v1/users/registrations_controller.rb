module Api
  module V1
    module Users
      class RegistrationsController < Devise::RegistrationsController
        respond_to :json

        private

        def respond_with(resource, _opts = {})
          if resource.persisted?
            render json: { user: { id: resource.id, email: resource.email } }, status: :created
          else
            render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def sign_up_params
          params.require(:user).permit(:email, :password, :password_confirmation)
        end
      end
    end
  end
end
