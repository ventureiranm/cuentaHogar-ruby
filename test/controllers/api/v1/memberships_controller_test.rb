require "test_helper"

class Api::V1::MembershipsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @household = households(:martinez)
    @owner_headers = auth_headers("lucia-token")
  end

  def member_headers
    _api_token, raw_token = ApiToken.issue_for(users(:diego))
    auth_headers(raw_token)
  end

  test "el owner invita a un usuario registrado por email" do
    post api_v1_household_memberships_path(@household), params: { email_address: "  PEDRO@example.com " },
                                                        headers: @owner_headers, as: :json

    assert_response :created
    body = response.parsed_body
    assert_equal users(:pedro).id, body["id"]
    assert_equal "Pedro Gómez", body["name"]
    assert_equal "member", body["role"]
    assert users(:pedro).member_of?(@household)
    assert_equal body["membership_id"], Membership.find_by(user: users(:pedro), household: @household).id
  end

  test "email no registrado da 404 con un mensaje claro" do
    post api_v1_household_memberships_path(@household), params: { email_address: "nadie@example.com" },
                                                        headers: @owner_headers, as: :json

    assert_response :not_found
    assert_equal [ "No hay ningún usuario registrado con el email nadie@example.com" ], response.parsed_body["errors"]
  end

  test "no duplica a quien ya es miembro" do
    post api_v1_household_memberships_path(@household), params: { email_address: "diego@example.com" },
                                                        headers: @owner_headers, as: :json

    assert_response :unprocessable_content
    assert_includes response.parsed_body["errors"], "Usuario ya es miembro de este hogar"
  end

  test "sin email_address da 400" do
    post api_v1_household_memberships_path(@household), params: {}, headers: @owner_headers, as: :json

    assert_response :bad_request
  end

  test "un miembro que no es owner no puede invitar" do
    post api_v1_household_memberships_path(@household), params: { email_address: "pedro@example.com" },
                                                        headers: member_headers, as: :json

    assert_response :forbidden
    assert_not users(:pedro).member_of?(@household)
  end

  test "en un hogar ajeno da 404" do
    post api_v1_household_memberships_path(households(:gomez)), params: { email_address: "diego@example.com" },
                                                                headers: @owner_headers, as: :json

    assert_response :not_found
  end

  test "el owner quita a un miembro" do
    delete api_v1_household_membership_path(@household, memberships(:diego_martinez)), headers: @owner_headers

    assert_response :no_content
    assert_not users(:diego).member_of?(@household)
  end

  test "un miembro que no es owner no puede quitar a nadie" do
    delete api_v1_household_membership_path(@household, memberships(:lucia_martinez)), headers: member_headers

    assert_response :forbidden
    assert users(:lucia).member_of?(@household)
  end

  test "el owner no puede quitarse a sí mismo" do
    delete api_v1_household_membership_path(@household, memberships(:lucia_martinez)), headers: @owner_headers

    assert_response :unprocessable_content
    assert users(:lucia).member_of?(@household)
  end

  test "no quita membresías de otro hogar" do
    delete api_v1_household_membership_path(@household, memberships(:pedro_gomez)), headers: @owner_headers

    assert_response :not_found
    assert users(:pedro).member_of?(households(:gomez))
  end
end
