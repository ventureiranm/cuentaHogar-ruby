require "test_helper"

class MonthlySummaryTest < ActiveSupport::TestCase
  setup do
    @summary = MonthlySummary.new(households(:martinez), Date.current)
  end

  test "totales del mes" do
    assert_equal 121_550, @summary.expenses_total
    assert_equal 1_040_000, @summary.incomes_total
    assert_equal 700_000, @summary.budget_total
    assert_equal 578_450, @summary.available
    assert_equal 1, @summary.pending_review_count
  end

  test "porcentaje de uso del presupuesto y variación contra el mes anterior" do
    assert_in_delta 17.4, @summary.budget_usage_percentage
    assert_in_delta 203.9, @summary.variation_percentage
  end

  test "gasto por categoría, incluyendo los que no tienen" do
    rows = @summary.by_category.to_h { |row| [ row[:category], row[:total] ] }

    assert_equal({ "Alimentos" => 48_320.0, "Sin categoría" => 41_230.0, "Transporte" => 32_000.0 }, rows)
  end

  test "sin gastos el mes anterior no hay variación" do
    summary = MonthlySummary.new(households(:gomez), Date.current)

    assert_nil summary.variation_percentage
    assert_in_delta 0.0, summary.budget_usage_percentage
  end

  test "to_h expone los datos para la API" do
    data = @summary.to_h

    assert_equal Date.current.strftime("%Y-%m"), data[:month]
    assert_in_delta 121_550.0, data[:expenses_total]
    assert_equal 3, data[:by_category].size
  end
end
