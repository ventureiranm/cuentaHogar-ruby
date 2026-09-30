require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  test "el nombre es único dentro del mismo hogar" do
    duplicated = Category.new(name: "servicios", household: households(:martinez))

    assert_not duplicated.valid?
    assert_includes duplicated.errors[:name], "ya está en uso"
  end

  test "el mismo nombre puede existir en otro hogar" do
    assert Category.new(name: "Servicios", household: households(:gomez)).valid?
  end

  test "no puede repetir el nombre de una categoría global" do
    assert_not Category.new(name: "Alimentos").valid?
  end

  test "el color debe ser hexadecimal" do
    category = Category.new(name: "Ocio", color: "rojo")

    assert_not category.valid?
    assert category.errors.of_kind?(:color, :invalid)
  end

  test "available_for devuelve las globales y las del hogar" do
    names = Category.available_for([ households(:martinez).id ]).pluck(:name)

    assert_includes names, "Alimentos"
    assert_includes names, "Servicios"
    assert_not_includes names, "Mascotas"
  end

  test "al eliminarla, sus gastos quedan pendientes de revisión" do
    categories(:transporte).destroy

    assert expenses(:nafta).reload.pending_review?
  end
end
