module Api
  module V1
    class RegistrationsController < BaseController
      skip_before_action :authenticate_api_user!

      # POST /api/v1/signup  { "user": { "name", "email_address", "password", "password_confirmation" } }
      def create
        @user = User.new(registration_params)

        if @user.save
          UserMailer.with(user: @user).welcome.deliver_later
          @api_token, @token = ApiToken.issue_for(@user)
          render "api/v1/sessions/create", status: :created
        else
          render_errors(@user)
        end
      end

      private
        def registration_params
          params.expect(user: [ :name, :email_address, :password, :password_confirmation ])
        end
    end
  end
end
