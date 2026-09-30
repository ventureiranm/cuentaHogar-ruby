require "test_helper"

class BudgetTest < ActiveSupport::TestCase
  test "el período se guarda como primer día del mes" do
    budget = Budget.new(household: households(:gomez), period: Date.new(2026, 9, 18), amount: 1000)

    assert_equal Date.new(2026, 9, 1), budget.period
  end

  test "acepta el formato YYYY-MM de un input month" do
    budget = Budget.new(household: households(:gomez), period: "2026-10", amount: 1000)

    assert_equal Date.new(2026, 10, 1), budget.period
    assert budget.valid?
  end

  test "no puede haber dos presupuestos iguales en el mismo mes" do
    duplicated = Budget.new(household: households(:martinez), period: Date.current, amount: 1)

    assert_not duplicated.valid?
    assert_includes duplicated.errors[:category_id], "ya tiene un presupuesto para ese mes"
  end

  test "calcula lo gastado, el restante y el porcentaje de uso por categoría" do
    budget = budgets(:alimentos_martinez)

    assert_equal 48_320, budget.spent
    assert_equal 1_680, budget.remaining
    assert_in_delta 96.6, budget.usage_percentage
    assert_not budget.exceeded?
  end

  test "el presupuesto general considera todos los gastos del mes" do
    budget = budgets(:general_martinez)

    assert_equal 121_550, budget.spent
    assert_equal "General", budget.label
  end

  test "detecta cuando se excede" do
    budget = budgets(:alimentos_martinez)
    budget.amount = 10_000

    assert budget.exceeded?
    assert_operator budget.remaining, :<, 0
  end
end
