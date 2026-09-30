require "test_helper"

class Api::V1::SummariesControllerTest < ActionDispatch::IntegrationTest
  setup { @headers = auth_headers("lucia-token") }

  test "resumen personal del mes con los mismos campos que el de un hogar" do
    get api_v1_summary_path(month: Date.current.strftime("%Y-%m")), headers: @headers

    assert_response :success
    body = response.parsed_body
    assert_nil body["household_id"]
    assert_in_delta 3_500.0, body["expenses_total"]
    assert_in_delta 0.0, body["budget_total"]
    assert_equal [ { "category" => "Alimentos", "total" => 3_500.0 } ], body["by_category"]

    get summary_api_v1_household_path(households(:martinez)), headers: @headers
    assert_equal response.parsed_body.keys.sort, body.keys.sort
  end

  test "otro mes sin movimientos" do
    get api_v1_summary_path(month: Date.current.next_month.strftime("%Y-%m")), headers: @headers

    assert_response :success
    assert_in_delta 0.0, response.parsed_body["expenses_total"]
  end

  test "requiere token" do
    get api_v1_summary_path

    assert_response :unauthorized
  end
end
