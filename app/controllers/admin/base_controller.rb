module Admin
  # Todo lo que hereda de acá exige sesión iniciada (concern Authentication)
  # y además que el usuario sea administrador.
  class BaseController < ApplicationController
    layout "admin"
    before_action :require_admin

    private
      def require_admin
        return if Current.user&.admin?

        terminate_session if Current.session
        redirect_to new_session_path, alert: "Necesitás una cuenta de administrador para entrar al back-office."
      end
  end
end
