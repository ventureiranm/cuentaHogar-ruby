# Datos de ejemplo basados en la pantalla principal de CuentaHogar.
# Se puede ejecutar varias veces: `bin/rails db:seed`
puts "Cargando datos de ejemplo..."

admin_email = ENV.fetch("ADMIN_EMAIL", "admin@cuentahogar.com")
admin_password = ENV.fetch("ADMIN_PASSWORD", "admin12345")

admin = User.find_or_initialize_by(email_address: admin_email)
admin.update!(name: "Admin CuentaHogar", password: admin_password, role: :admin)

demo_password = "cuentahogar123"
lucia = User.find_or_create_by!(email_address: "lucia.martinez@mail.com") do |user|
  user.name = "Lucía Martínez"
  user.password = demo_password
end
diego = User.find_or_create_by!(email_address: "diego.martinez@mail.com") do |user|
  user.name = "Diego Martínez"
  user.password = demo_password
end
sofia = User.find_or_create_by!(email_address: "sofia.martinez@mail.com") do |user|
  user.name = "Sofía Martínez"
  user.password = demo_password
end

hogar = Household.find_or_create_by!(name: "Hogar Martínez")
{ lucia => :owner, diego => :member, sofia => :member }.each do |user, role|
  hogar.memberships.find_or_create_by!(user: user) { |membership| membership.role = role }
end

categories = {
  "Alimentos" => "#2F4F4A", "Transporte" => "#4A6FA5", "Educación" => "#C9A86A",
  "Salud" => "#8A3A32", "Servicios" => "#6D736C", "Vivienda" => "#22332F"
}.to_h do |name, color|
  [ name, Category.find_or_create_by!(name: name, household: nil) { |category| category.color = color } ]
end

month = Date.current.beginning_of_month

if hogar.expenses.none?
  [
    [ lucia, "Supermercado Disco", "Alimentos", 48_320, 9, false ],
    [ diego, "Nafta — YPF Av. Rivadavia", "Transporte", 32_000, 8, false ],
    [ lucia, "Cuota colegio", "Educación", 96_500, 7, true ],
    [ sofia, "Farmacia — medicamentos", "Salud", 14_780, 5, false ],
    [ lucia, "Edenor — factura de luz", "Servicios", 41_230, 4, true ],
    [ lucia, "Alquiler", "Vivienda", 180_020, 2, true ]
  ].each do |user, description, category, amount, day, recurring|
    hogar.expenses.create!(user: user, description: description, category: categories[category],
                           amount: amount, spent_on: month + (day - 1), recurring: recurring)
  end

  # Importados del resumen bancario, todavía sin categoría.
  3.times do |i|
    hogar.expenses.create!(user: lucia, description: "Consumo tarjeta ##{i + 1}", amount: 5_000 * (i + 1),
                           spent_on: month + i, source: :imported)
  end

  hogar.expenses.create!(user: diego, description: "Supermercado mes anterior", category: categories["Alimentos"],
                         amount: 250_000, spent_on: month.prev_month + 10)
end

lucia.expenses.personal.find_or_create_by!(description: "Café con amigas") do |expense|
  expense.amount = 6_500
  expense.spent_on = month
  expense.category = categories["Alimentos"]
end

if hogar.incomes.none?
  hogar.incomes.create!(user: lucia, description: "Sueldo Lucía", amount: 520_000, received_on: month)
  hogar.incomes.create!(user: diego, description: "Sueldo Diego", amount: 440_000, received_on: month)
  hogar.incomes.create!(user: sofia, description: "Aporte Sofía", amount: 80_000, received_on: month + 1)
end

hogar.budgets.find_or_create_by!(period: month, category: nil) { |budget| budget.amount = 700_000 }
hogar.budgets.find_or_create_by!(period: month, category: categories["Alimentos"]) { |budget| budget.amount = 120_000 }

[
  [ "Tarjeta Visa", 128_400, 0 ],
  [ "Internet — Fibertel", 29_900, 4 ],
  [ "Prepaga OSDE", 214_700, 9 ]
].each do |title, amount, days|
  hogar.reminders.find_or_create_by!(title: title) do |reminder|
    reminder.amount = amount
    reminder.due_on = Date.current + days
    reminder.user = lucia
  end
end

puts "Listo. Back-office: #{admin_email} / #{admin_password}"
puts "Usuarios de la API: lucia.martinez@mail.com / #{demo_password} (también diego y sofia)"
