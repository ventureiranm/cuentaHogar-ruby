require "test_helper"

class Admin::AccessTest < ActionDispatch::IntegrationTest
  test "sin sesión redirige al login" do
    get admin_root_path

    assert_redirected_to new_session_path
  end

  test "un usuario final no puede iniciar sesión en el back-office" do
    sign_in_as users(:lucia)

    assert_redirected_to new_session_path
    follow_redirect!
    assert_select ".flash--alert", /no tiene acceso/
  end

  test "credenciales incorrectas" do
    sign_in_as users(:admin), password: "incorrecta"

    assert_redirected_to new_session_path
    follow_redirect!
    assert_select ".flash--alert", /incorrectos/
  end

  test "el administrador entra al resumen" do
    sign_in_as users(:admin)
    get admin_root_path

    assert_response :success
    assert_select "h1", "Resumen del mes"
    assert_select "a", text: "Hogar Martínez"
  end

  test "cerrar sesión" do
    sign_in_as users(:admin)
    delete session_path
    get admin_root_path

    assert_redirected_to new_session_path
  end
end
