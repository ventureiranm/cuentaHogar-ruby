# Vista previa: http://localhost:3000/rails/mailers/user_mailer/welcome
class UserMailerPreview < ActionMailer::Preview
  def welcome
    UserMailer.with(user: User.first).welcome
  end
end
