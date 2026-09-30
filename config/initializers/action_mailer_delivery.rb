# Envío de emails fuera de los tests.
#
# - Si están definidas las variables SMTP_*, los mails salen por SMTP real
#   (por ejemplo Gmail con una "contraseña de aplicación").
# - Si no, en development se guardan como archivos en tmp/mails/ para poder revisarlos.
#
# Las vistas previas están siempre en http://localhost:3000/rails/mailers
unless Rails.env.test?
  ActiveSupport.on_load(:action_mailer) do
    if ENV["SMTP_ADDRESS"].present?
      self.delivery_method = :smtp
      self.smtp_settings = {
        address: ENV["SMTP_ADDRESS"],
        port: ENV.fetch("SMTP_PORT", 587).to_i,
        user_name: ENV["SMTP_USERNAME"],
        password: ENV["SMTP_PASSWORD"],
        authentication: :plain,
        enable_starttls_auto: true
      }
      self.perform_deliveries = true
      self.raise_delivery_errors = true
    elsif Rails.env.development?
      self.delivery_method = :file
    end
  end
end
