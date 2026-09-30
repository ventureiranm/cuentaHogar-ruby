class Budget < ApplicationRecord
  MONTH_FORMAT = /\A\d{4}-\d{2}\z/

  belongs_to :household
  belongs_to :category, optional: true

  # Un presupuesto siempre corresponde a un mes completo.
  normalizes :period, with: ->(date) { date.beginning_of_month }

  validates :period, presence: true
  validates :amount, numericality: { greater_than: 0, less_than: 10_000_000_000 }
  validates :category_id, uniqueness: { scope: [ :household_id, :period ],
                                        message: "ya tiene un presupuesto para ese mes" }
  validate :category_must_match_household

  scope :for_month, ->(date) { where(period: date.to_date.beginning_of_month) }
  scope :general, -> { where(category_id: nil) }
  scope :chronological, -> { order(period: :desc) }

  # Acepta "2026-09" (lo que envía un <input type="month">) además de fechas completas.
  def period=(value)
    value = "#{value}-01" if value.is_a?(String) && value.match?(MONTH_FORMAT)
    super
  end

  def label
    category ? category.name : "General"
  end

  def spent
    @spent ||= begin
      scope = household.expenses.in_month(period)
      scope = scope.where(category_id: category_id) if category_id
      scope.sum(:amount)
    end
  end

  def remaining
    amount - spent
  end

  def usage_percentage
    return 0.0 if amount.blank? || amount.zero?

    (spent * 100 / amount).round(1).to_f
  end

  def exceeded?
    spent > amount
  end

  private
    def category_must_match_household
      return if category.nil? || category.global? || category.household_id == household_id

      errors.add(:category, "no pertenece a este hogar")
    end
end
