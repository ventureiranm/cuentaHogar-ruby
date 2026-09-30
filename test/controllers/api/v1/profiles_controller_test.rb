require "test_helper"

class Api::V1::ProfilesControllerTest < ActionDispatch::IntegrationTest
  test "sin token responde 401" do
    get api_v1_profile_path

    assert_response :unauthorized
    assert_equal [ "Token inválido, vencido o ausente" ], response.parsed_body["errors"]
  end

  test "token vencido responde 401" do
    get api_v1_profile_path, headers: auth_headers("expired-token")

    assert_response :unauthorized
  end

  test "devuelve el perfil del usuario autenticado" do
    get api_v1_profile_path, headers: auth_headers("lucia-token")

    assert_response :success
    assert_equal "lucia@example.com", response.parsed_body["email_address"]
    assert_equal "LM", response.parsed_body["initials"]
  end

  test "cambiar la contraseña exige la actual" do
    patch api_v1_profile_path, params: { user: { password: "nuevaclave1", password_confirmation: "nuevaclave1" } },
                               headers: auth_headers("lucia-token"), as: :json
    assert_response :unprocessable_content

    patch api_v1_profile_path, params: { user: { password: "nuevaclave1", password_confirmation: "nuevaclave1",
                                                 password_challenge: "incorrecta" } },
                               headers: auth_headers("lucia-token"), as: :json
    assert_response :unprocessable_content

    patch api_v1_profile_path, params: { user: { name: "Lucía M.", password: "nuevaclave1",
                                                 password_confirmation: "nuevaclave1", password_challenge: "password123" } },
                               headers: auth_headers("lucia-token"), as: :json
    assert_response :success
    assert users(:lucia).reload.authenticate("nuevaclave1")
  end
end
