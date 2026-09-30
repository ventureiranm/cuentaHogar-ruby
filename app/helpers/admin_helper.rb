module AdminHelper
  def admin_nav_link(label, path, section)
    active = controller_name == section.to_s
    link_to label, path, class: class_names("nav-link", "is-active": active)
  end

  def reminder_badge(reminder)
    css = {
      "pagado" => "badge--ok",
      "vencido" => "badge--danger",
      "vence hoy" => "badge--warn"
    }.fetch(reminder.status, "badge--muted")
    tag.span(reminder.status.capitalize, class: "badge #{css}")
  end

  def usage_bar(percentage)
    width = percentage.to_f.clamp(0, 100)
    tag.div(class: class_names("usage-bar", "usage-bar--over": percentage.to_f > 100)) do
      tag.div(class: "usage-bar__fill", style: "width: #{width}%")
    end
  end

  def color_swatch(color)
    tag.span(class: "swatch", style: "background: #{color}")
  end
end
