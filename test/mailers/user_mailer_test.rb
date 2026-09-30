require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "welcome" do
    user = users(:lucia)
    mail = UserMailer.with(user: user).welcome

    assert_equal [ user.email_address ], mail.to
    assert_equal "¡Bienvenido/a a CuentaHogar, #{user.name}!", mail.subject
    assert_match "Tu cuenta de CuentaHogar ya está lista", mail.text_part.decoded
  end
end
