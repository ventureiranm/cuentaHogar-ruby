require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "normaliza el email y el nombre" do
    user = User.new(name: "  Ana   Pérez ", email_address: "  ANA@Example.COM ", password: "password123")

    assert_equal "ana@example.com", user.email_address
    assert_equal "Ana Pérez", user.name
  end

  test "requiere nombre y email con formato válido" do
    user = User.new(password: "password123", email_address: "no-es-un-email")

    assert_not user.valid?
    assert_includes user.errors[:name], "no puede estar en blanco"
    assert_includes user.errors[:email_address], "no es válido"
  end

  test "el email es único sin importar mayúsculas" do
    user = User.new(name: "Otra Lucía", email_address: "LUCIA@example.com", password: "password123")

    assert_not user.valid?
    assert_includes user.errors[:email_address], "ya está en uso"
  end

  test "la contraseña debe tener al menos 8 caracteres" do
    user = User.new(name: "Ana", email_address: "ana@example.com", password: "corta")

    assert_not user.valid?
    assert user.errors.of_kind?(:password, :too_short)
  end

  test "por defecto es usuario final" do
    assert User.new.member?
    assert users(:admin).admin?
  end

  test "iniciales y pertenencia a hogares" do
    assert_equal "LM", users(:lucia).initials
    assert users(:lucia).member_of?(households(:martinez))
    assert_not users(:lucia).member_of?(households(:gomez))
    assert_not users(:lucia).member_of?(nil)
  end
end
