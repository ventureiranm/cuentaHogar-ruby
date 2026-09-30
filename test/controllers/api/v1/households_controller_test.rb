require "test_helper"

class Api::V1::HouseholdsControllerTest < ActionDispatch::IntegrationTest
  setup { @headers = auth_headers("lucia-token") }

  test "lista los hogares del usuario con sus miembros" do
    get api_v1_households_path, headers: @headers

    assert_response :success
    assert_equal [ "Hogar Martínez" ], response.parsed_body.pluck("name")
    assert_equal 2, response.parsed_body.first["members"].size
  end

  test "resumen mensual" do
    get summary_api_v1_household_path(households(:martinez), month: Date.current.strftime("%Y-%m")), headers: @headers

    assert_response :success
    body = response.parsed_body
    assert_in_delta 121_550.0, body["expenses_total"]
    assert_in_delta 578_450.0, body["available"]
    assert_equal 1, body["pending_review_count"]
  end

  test "no accede a hogares ajenos" do
    get api_v1_household_path(households(:gomez)), headers: @headers

    assert_response :not_found
  end

  test "crear un hogar deja al usuario como owner" do
    post api_v1_households_path, params: { household: { name: "Casa de la costa", currency: "ARS" } },
                                 headers: @headers, as: :json

    assert_response :created
    assert_equal "owner", response.parsed_body.dig("members", 0, "role")
    assert users(:lucia).member_of?(Household.find(response.parsed_body["id"]))
  end
end
