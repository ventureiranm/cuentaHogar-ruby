require "test_helper"

# Categorías, ingresos, presupuestos y vencimientos.
class Api::V1::PlanningControllerTest < ActionDispatch::IntegrationTest
  setup { @headers = auth_headers("lucia-token") }

  test "categorías disponibles" do
    get api_v1_categories_path, headers: @headers

    names = response.parsed_body.pluck("name")
    assert_includes names, "Servicios"
    assert_not_includes names, "Mascotas"
  end

  test "ingresos del hogar" do
    get api_v1_incomes_path(household_id: households(:martinez).id), headers: @headers

    assert_response :success
    assert_equal 2, response.parsed_body.size
  end

  test "presupuestos con lo gastado" do
    get api_v1_budgets_path(household_id: households(:martinez).id), headers: @headers

    assert_response :success
    alimentos = response.parsed_body.find { |budget| budget["label"] == "Alimentos" }
    assert_in_delta 48_320.0, alimentos["spent"]
    assert_in_delta 96.6, alimentos["usage_percentage"]
  end

  test "presupuestos requieren household_id" do
    get api_v1_budgets_path, headers: @headers

    assert_response :bad_request
  end

  test "crear un presupuesto" do
    post api_v1_budgets_path, params: { budget: {
      household_id: households(:martinez).id, category_id: categories(:transporte).id, period: "2026-12", amount: 90_000
    } }, headers: @headers, as: :json

    assert_response :created
    assert_equal "2026-12", response.parsed_body["period"]
  end

  test "vencimientos pendientes y marcar como pagado" do
    get api_v1_reminders_path, headers: @headers
    assert_response :success
    titles = response.parsed_body.pluck("title")
    assert_includes titles, "Tarjeta Visa"
    assert_not_includes titles, "Expensas"
    assert_not_includes titles, "Alquiler"

    patch pay_api_v1_reminder_path(reminders(:visa)), headers: @headers
    assert_response :success
    assert_equal "pagado", response.parsed_body["status"]
  end

  test "crear un vencimiento en un hogar ajeno da 404" do
    post api_v1_reminders_path, params: { reminder: {
      household_id: households(:gomez).id, title: "Luz", due_on: Date.current
    } }, headers: @headers, as: :json

    assert_response :not_found
  end
end
