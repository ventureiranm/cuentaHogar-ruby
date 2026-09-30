module Api
  module V1
    class SessionsController < BaseController
      skip_before_action :authenticate_api_user!, only: :create

      # POST /api/v1/login  { "email_address": "...", "password": "..." }
      def create
        credentials = params.permit(:email_address, :password)
        @user = User.authenticate_by(email_address: credentials[:email_address].to_s,
                                     password: credentials[:password].to_s)

        if @user
          @api_token, @token = ApiToken.issue_for(@user)
          render :create, status: :created
        else
          render json: { errors: [ "Email o contraseña incorrectos" ] }, status: :unauthorized
        end
      end

      # DELETE /api/v1/logout — revoca el token usado en el request.
      def destroy
        current_api_token.destroy!
        head :no_content
      end
    end
  end
end
