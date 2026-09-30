# Vista previa: http://localhost:3000/rails/mailers/reminder_mailer/due_soon
class ReminderMailerPreview < ActionMailer::Preview
  def due_soon
    reminder = Reminder.joins(household: :memberships).first
    ReminderMailer.with(reminder: reminder, user: reminder.household.members.first).due_soon
  end
end
