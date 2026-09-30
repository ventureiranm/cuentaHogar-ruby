class ReminderMailer < ApplicationMailer
  # Aviso a cada miembro del hogar de un vencimiento próximo.
  def due_soon
    @reminder = params[:reminder]
    @user = params[:user]
    @household = @reminder.household
    mail to: @user.email_address, subject: "Vencimiento próximo: #{@reminder.title}"
  end
end
