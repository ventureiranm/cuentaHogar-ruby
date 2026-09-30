# Recordatorio de vencimiento (tarjeta, servicios, prepaga, etc.).
class Reminder < ApplicationRecord
  DUE_SOON_DAYS = 3

  belongs_to :household
  belongs_to :user, optional: true

  validates :title, presence: true, length: { maximum: 80 }
  validates :due_on, presence: true
  validates :amount, numericality: { greater_than: 0, less_than: 10_000_000_000 }, allow_nil: true

  scope :chronological, -> { order(:due_on, :id) }
  scope :pending, -> { where(paid_at: nil) }
  scope :paid, -> { where.not(paid_at: nil) }
  scope :overdue, -> { pending.where(due_on: ...Date.current) }
  scope :due_within, ->(days) { pending.where(due_on: Date.current..(Date.current + days)) }
  scope :to_notify, -> { due_within(DUE_SOON_DAYS).where(notified_at: nil) }

  def paid?
    paid_at.present?
  end
  alias_method :paid, :paid?

  # Permite marcar/desmarcar como pagado desde un checkbox.
  def paid=(value)
    self.paid_at = ActiveModel::Type::Boolean.new.cast(value) ? (paid_at || Time.current) : nil
  end

  def overdue?
    !paid? && due_on.present? && due_on < Date.current
  end

  def days_until_due
    (due_on - Date.current).to_i
  end

  def status
    return "pagado" if paid?
    return "vencido" if overdue?
    return "vence hoy" if days_until_due.zero?

    "pendiente"
  end

  def mark_as_paid!
    update!(paid_at: Time.current)
  end

  def notify_members!
    household.members.find_each do |member|
      ReminderMailer.with(reminder: self, user: member).due_soon.deliver_now
    end
    update!(notified_at: Time.current)
  end
end
