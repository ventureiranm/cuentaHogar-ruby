require "test_helper"

class ReminderTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  test "requiere concepto y fecha" do
    reminder = Reminder.new(household: households(:martinez))

    assert_not reminder.valid?
    assert reminder.errors.of_kind?(:title, :blank)
    assert reminder.errors.of_kind?(:due_on, :blank)
  end

  test "estado según la fecha y el pago" do
    assert_equal "vence hoy", reminders(:visa).status
    assert_equal "pendiente", reminders(:internet).status
    assert_equal "vencido", reminders(:vencido).status
    assert_equal "pagado", reminders(:pagado).status
    assert reminders(:vencido).overdue?
    assert_equal 2, reminders(:internet).days_until_due
  end

  test "scopes de vencimientos" do
    assert_equal [ reminders(:vencido) ], Reminder.overdue.to_a
    assert_equal [ reminders(:visa), reminders(:alquiler_gomez), reminders(:internet) ].sort,
                 Reminder.to_notify.to_a.sort
  end

  test "marcar como pagado" do
    reminder = reminders(:visa)
    reminder.mark_as_paid!

    assert reminder.reload.paid?
    assert_not_includes Reminder.pending, reminder
  end

  test "el checkbox paid setea o limpia paid_at" do
    reminder = reminders(:visa)
    reminder.paid = "1"
    assert reminder.paid?

    reminder.paid = "0"
    assert_nil reminder.paid_at
  end

  test "notify_members! envía un email a cada miembro y registra el aviso" do
    reminder = reminders(:visa)

    assert_emails 2 do
      reminder.notify_members!
    end
    assert reminder.reload.notified_at.present?
    assert_not_includes Reminder.to_notify, reminder
  end
end
