require "test_helper"

class ExpenseTest < ActiveSupport::TestCase
  def build_expense(**attributes)
    Expense.new({ user: users(:lucia), household: households(:martinez), category: categories(:alimentos),
                  description: "Verdulería", amount: 5000, spent_on: Date.current }.merge(attributes))
  end

  test "un gasto completo es válido" do
    assert build_expense.valid?
  end

  test "requiere detalle, fecha y un monto positivo" do
    expense = build_expense(description: "", spent_on: nil, amount: 0)

    assert_not expense.valid?
    assert expense.errors.of_kind?(:description, :blank)
    assert expense.errors.of_kind?(:spent_on, :blank)
    assert expense.errors.of_kind?(:amount, :greater_than)
  end

  test "el usuario tiene que ser miembro del hogar" do
    expense = build_expense(user: users(:pedro))

    assert_not expense.valid?
    assert expense.errors[:household].any?
  end

  test "sin hogar es un gasto personal" do
    expense = build_expense(household: nil, user: users(:pedro))

    assert expense.valid?
    assert expense.personal?
    assert_equal "Personal", expense.scope_name
  end

  test "no acepta una categoría de otro hogar" do
    expense = build_expense(category: categories(:mascotas_gomez))

    assert_not expense.valid?
    assert_includes expense.errors[:category], "no pertenece a este hogar"
  end

  test "sin categoría queda pendiente de revisión" do
    assert expenses(:luz).pending_review?
    assert_equal [ expenses(:luz) ], Expense.pending_review.to_a
  end

  test "visible_to incluye el hogar y lo personal propio, pero no lo ajeno" do
    visible = Expense.visible_to(users(:lucia))

    assert_includes visible, expenses(:nafta)
    assert_includes visible, expenses(:cafe_personal)
    assert_not_includes visible, expenses(:veterinaria)
    assert_not_includes Expense.visible_to(users(:diego)), expenses(:cafe_personal)
  end

  test "acepta un comprobante PNG" do
    expense = build_expense
    expense.receipt.attach(io: file_fixture("comprobante.png").open, filename: "comprobante.png")

    assert expense.save
    assert expense.receipt.attached?
  end

  test "rechaza comprobantes que no son imagen ni PDF" do
    expense = build_expense
    expense.receipt.attach(io: file_fixture("nota.txt").open, filename: "nota.txt", content_type: "text/plain")

    assert_not expense.valid?
    assert_includes expense.errors[:receipt], "debe ser una imagen JPG/PNG o un PDF"
  end
end
