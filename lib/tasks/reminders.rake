namespace :reminders do
  desc "Envía un email a los miembros de cada hogar por los vencimientos de los próximos días"
  task notify: :environment do
    reminders = Reminder.to_notify.includes(:household)
    reminders.each(&:notify_members!)
    puts "Vencimientos notificados: #{reminders.size}"
  end
end
