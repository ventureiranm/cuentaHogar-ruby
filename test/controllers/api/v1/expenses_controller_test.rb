require "test_helper"

class Api::V1::ExpensesControllerTest < ActionDispatch::IntegrationTest
  setup { @headers = auth_headers("lucia-token") }

  test "lista solo los gastos visibles para el usuario" do
    get api_v1_expenses_path, headers: @headers

    assert_response :success
    ids = response.parsed_body.pluck("id")
    assert_includes ids, expenses(:nafta).id
    assert_includes ids, expenses(:cafe_personal).id
    assert_not_includes ids, expenses(:veterinaria).id
  end

  test "filtros por ámbito, mes y pendientes" do
    get api_v1_expenses_path(scope: "personal"), headers: @headers
    assert_equal [ expenses(:cafe_personal).id ], response.parsed_body.pluck("id")

    get api_v1_expenses_path(household_id: households(:martinez).id, month: Date.current.strftime("%Y-%m")),
        headers: @headers
    assert_equal 3, response.parsed_body.size

    get api_v1_expenses_path(pending: "true"), headers: @headers
    assert_equal [ expenses(:luz).id ], response.parsed_body.pluck("id")
    assert response.parsed_body.first["pending_review"]
    assert_nil response.parsed_body.first["category"]
  end

  test "detalle de un gasto" do
    get api_v1_expense_path(expenses(:supermercado)), headers: @headers

    assert_response :success
    body = response.parsed_body
    assert_in_delta 48_320.0, body["amount"]
    assert_equal "Alimentos", body.dig("category", "name")
    assert_equal "Hogar Martínez", body["scope_name"]
  end

  test "no puede ver gastos de otro hogar" do
    get api_v1_expense_path(expenses(:veterinaria)), headers: @headers

    assert_response :not_found
  end

  test "crear un gasto en su hogar" do
    assert_difference "Expense.count", 1 do
      post api_v1_expenses_path, params: { expense: {
        description: "Panadería", amount: 3200, spent_on: Date.current,
        household_id: households(:martinez).id, category_id: categories(:alimentos).id
      } }, headers: @headers, as: :json
    end

    assert_response :created
    assert_equal users(:lucia).id, response.parsed_body.dig("user", "id")
  end

  test "crear un gasto con comprobante (multipart)" do
    post api_v1_expenses_path, params: { expense: {
      description: "Farmacia", amount: "1500", spent_on: Date.current.to_s,
      receipt: fixture_file_upload("comprobante.png", "image/png")
    } }, headers: @headers

    assert_response :created
    assert response.parsed_body["receipt_url"].present?
  end

  test "no puede cargar gastos en un hogar ajeno" do
    assert_no_difference "Expense.count" do
      post api_v1_expenses_path, params: { expense: {
        description: "Intento", amount: 100, spent_on: Date.current, household_id: households(:gomez).id
      } }, headers: @headers, as: :json
    end

    assert_response :unprocessable_content
    assert response.parsed_body["errors"].any?
  end

  test "actualizar y eliminar" do
    expense = expenses(:luz)

    patch api_v1_expense_path(expense), params: { expense: { category_id: categories(:servicios_martinez).id } },
                                        headers: @headers, as: :json
    assert_response :success
    assert_not expense.reload.pending_review?

    assert_difference "Expense.count", -1 do
      delete api_v1_expense_path(expense), headers: @headers
    end
    assert_response :no_content
  end
end
