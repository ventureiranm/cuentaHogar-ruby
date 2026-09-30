class UserMailer < ApplicationMailer
  # Se envía cuando un usuario final se registra desde la API.
  def welcome
    @user = params[:user]
    mail to: @user.email_address, subject: "¡Bienvenido/a a CuentaHogar, #{@user.name}!"
  end
end
