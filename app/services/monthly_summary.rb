# Resumen mensual: lo que muestra la pantalla "Resumen del mes".
# Se calcula sobre un hogar (MonthlySummary.new(household)) o sobre el ámbito
# Personal de un usuario (MonthlySummary.personal(user)): los cálculos son los
# mismos, solo cambian los movimientos de los que parten.
class MonthlySummary
  attr_reader :household, :user, :month

  def self.personal(user, month = Date.current)
    new(nil, month, user: user)
  end

  def initialize(household, month = Date.current, user: nil)
    raise ArgumentError, "MonthlySummary necesita un hogar o un usuario" if household.nil? && user.nil?

    @household = household
    @user = user
    @month = month.to_date.beginning_of_month
  end

  def personal?
    household.nil?
  end

  def expenses_total
    @expenses_total ||= expenses_in(month).sum(:amount)
  end

  def previous_expenses_total
    @previous_expenses_total ||= expenses_in(month.prev_month).sum(:amount)
  end

  def incomes_total
    @incomes_total ||= incomes.in_month(month).sum(:amount)
  end

  # Presupuesto general del mes (el que no tiene categoría).
  def budget_total
    @budget_total ||= budgets.for_month(month).general.sum(:amount)
  end

  def available
    budget_total - expenses_total
  end

  def budget_usage_percentage
    return 0.0 if budget_total.zero?

    (expenses_total * 100 / budget_total).round(1).to_f
  end

  # Variación porcentual contra el mes anterior. nil si el mes anterior no tuvo gastos.
  def variation_percentage
    return nil if previous_expenses_total.zero?

    ((expenses_total - previous_expenses_total) * 100 / previous_expenses_total).round(1).to_f
  end

  def pending_review_count
    expenses_in(month).pending_review.count
  end

  def by_category
    expenses_in(month)
      .left_joins(:category)
      .group("categories.name")
      .sum(:amount)
      .map { |name, total| { category: name || "Sin categoría", total: total.to_f } }
      .sort_by { |row| -row[:total] }
  end

  def to_h
    {
      household_id: household&.id,
      month: month.strftime("%Y-%m"),
      expenses_total: expenses_total.to_f,
      previous_expenses_total: previous_expenses_total.to_f,
      variation_percentage: variation_percentage,
      incomes_total: incomes_total.to_f,
      budget_total: budget_total.to_f,
      available: available.to_f,
      budget_usage_percentage: budget_usage_percentage,
      pending_review_count: pending_review_count,
      by_category: by_category
    }
  end

  private
    def expenses
      personal? ? user.expenses.personal : household.expenses
    end

    def incomes
      personal? ? user.incomes.personal : household.incomes
    end

    # Los presupuestos siempre pertenecen a un hogar: en el ámbito Personal no hay.
    def budgets
      personal? ? Budget.none : household.budgets
    end

    def expenses_in(date)
      expenses.in_month(date)
    end
end
