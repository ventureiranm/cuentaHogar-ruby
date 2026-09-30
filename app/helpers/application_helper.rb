module ApplicationHelper
  # Formato de moneda argentino: $ 412.850,00
  def money(amount, currency: "ARS")
    return "—" if amount.nil?

    unit = currency == "USD" ? "US$ " : "$ "
    number_to_currency(amount, unit: unit, precision: 2, delimiter: ".", separator: ",", format: "%u%n")
  end

  # Etiqueta legible de un enum, definida en config/locales/es.yml (clave enums).
  def enum_label(model_class, attribute, value)
    return "—" if value.blank?

    t("enums.#{model_class.model_name.i18n_key}.#{attribute}.#{value}")
  end

  def enum_options(model_class, attribute)
    model_class.public_send(attribute.to_s.pluralize).keys.map do |value|
      [ enum_label(model_class, attribute, value), value ]
    end
  end
end
