require "test_helper"

class Api::V1::SessionsControllerTest < ActionDispatch::IntegrationTest
  test "login correcto devuelve un token" do
    assert_difference "ApiToken.count", 1 do
      post api_v1_login_path, params: { email_address: "LUCIA@example.com", password: "password123" }, as: :json
    end

    assert_response :created
    body = response.parsed_body
    assert body["token"].present?
    assert_equal "Bearer", body["token_type"]
    assert_equal "Lucía Martínez", body.dig("user", "name")
    assert_equal "Hogar Martínez", body.dig("user", "households", 0, "name")
  end

  test "login con credenciales incorrectas" do
    post api_v1_login_path, params: { email_address: "lucia@example.com", password: "mala" }, as: :json

    assert_response :unauthorized
    assert_equal [ "Email o contraseña incorrectos" ], response.parsed_body["errors"]
  end

  test "login sin datos no rompe" do
    post api_v1_login_path, params: {}, as: :json

    assert_response :unauthorized
  end

  test "logout revoca el token" do
    delete api_v1_logout_path, headers: auth_headers("lucia-token")
    assert_response :no_content

    get api_v1_profile_path, headers: auth_headers("lucia-token")
    assert_response :unauthorized
  end

  test "registro crea el usuario, envía el email de bienvenida y devuelve token" do
    assert_difference "User.count", 1 do
      assert_enqueued_emails 1 do
        post api_v1_signup_path, params: { user: {
          name: "Sofía Martínez", email_address: "sofia@example.com",
          password: "password123", password_confirmation: "password123", role: "admin"
        } }, as: :json
      end
    end

    assert_response :created
    assert response.parsed_body["token"].present?
    assert User.find_by!(email_address: "sofia@example.com").member?, "el rol no se puede elegir desde la API"
  end

  test "registro inválido devuelve los errores" do
    post api_v1_signup_path, params: { user: { name: "", email_address: "lucia@example.com", password: "123" } }, as: :json

    assert_response :unprocessable_content
    assert_operator response.parsed_body["errors"].size, :>=, 3
  end
end
