module Api
  module V1
    class ProfilesController < BaseController
      before_action :set_user

      # GET /api/v1/profile
      def show
      end

      # PATCH /api/v1/profile  { "user": { "name", "password", "password_confirmation", "password_challenge" } }
      def update
        attributes = profile_params
        if attributes[:password].present? && attributes[:password_challenge].blank?
          return render_errors([ "Para cambiar la contraseña ingresá la actual en password_challenge" ])
        end

        if @user.update(attributes)
          render :show
        else
          render_errors(@user)
        end
      end

      private
        def set_user
          @user = current_user
        end

        # password_challenge: has_secure_password valida que coincida con la contraseña actual.
        def profile_params
          params.expect(user: [ :name, :password, :password_confirmation, :password_challenge ])
        end
    end
  end
end
