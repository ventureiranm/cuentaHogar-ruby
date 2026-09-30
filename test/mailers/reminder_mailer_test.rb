require "test_helper"

class ReminderMailerTest < ActionMailer::TestCase
  test "due_soon" do
    reminder = reminders(:visa)
    mail = ReminderMailer.with(reminder: reminder, user: users(:diego)).due_soon

    assert_equal [ "diego@example.com" ], mail.to
    assert_equal "Vencimiento próximo: Tarjeta Visa", mail.subject
    assert_match "Hogar Martínez", mail.html_part.decoded
    assert_match "$ 128.400,00", mail.text_part.decoded
  end
end
