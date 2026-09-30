class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAILER_FROM", "CuentaHogar <no-reply@cuentahogar.local>")
  layout "mailer"
  helper ApplicationHelper
end
