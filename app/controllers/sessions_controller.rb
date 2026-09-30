# Login del back-office (autenticación nativa de Rails 8: `bin/rails generate authentication`).
# Solo los usuarios con rol admin pueden iniciar sesión acá.
class SessionsController < ApplicationController
  layout "auth"
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create,
             with: -> { redirect_to new_session_url, alert: "Demasiados intentos. Probá de nuevo en unos minutos." }

  def new
  end

  def create
    user = User.authenticate_by(params.permit(:email_address, :password))

    if user&.admin?
      start_new_session_for user
      redirect_to after_authentication_url
    elsif user
      redirect_to new_session_path, alert: "Tu cuenta no tiene acceso al back-office."
    else
      redirect_to new_session_path, alert: "Email o contraseña incorrectos."
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, status: :see_other, notice: "Sesión cerrada."
  end
end
