require "test_helper"

class Admin::CrudTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:admin) }

  test "listados y formularios responden" do
    [
      admin_users_path, new_admin_user_path, admin_user_path(users(:lucia)),
      admin_households_path, new_admin_household_path, admin_household_path(households(:martinez)),
      admin_categories_path, new_admin_category_path, edit_admin_category_path(categories(:alimentos)),
      admin_expenses_path, admin_expenses_path(pending: 1, household_id: households(:martinez).id),
      new_admin_expense_path, admin_expense_path(expenses(:supermercado)), edit_admin_expense_path(expenses(:supermercado)),
      admin_incomes_path, new_admin_income_path, edit_admin_income_path(incomes(:sueldo_lucia)),
      admin_budgets_path, new_admin_budget_path, edit_admin_budget_path(budgets(:general_martinez)),
      admin_reminders_path, admin_reminders_path(status: "paid"), new_admin_reminder_path,
      edit_admin_reminder_path(reminders(:visa))
    ].each do |path|
      get path
      assert_response :success, "Falló GET #{path}"
    end
  end

  test "crear, editar y eliminar una categoría" do
    assert_difference "Category.count", 1 do
      post admin_categories_path, params: { category: { name: "Ocio", color: "#123456", household_id: "" } }
    end
    category = Category.find_by!(name: "Ocio")
    assert_redirected_to admin_categories_path

    patch admin_category_path(category), params: { category: { name: "Salidas" } }
    assert_equal "Salidas", category.reload.name

    assert_difference "Category.count", -1 do
      delete admin_category_path(category)
    end
  end

  test "crear un gasto con comprobante" do
    assert_difference "Expense.count", 1 do
      post admin_expenses_path, params: { expense: {
        description: "Ferretería", amount: "15000.50", spent_on: Date.current,
        user_id: users(:diego).id, household_id: households(:martinez).id, category_id: "",
        source: "manual", recurring: "0",
        receipt: fixture_file_upload("comprobante.png", "image/png")
      } }
    end

    expense = Expense.order(:id).last
    assert_redirected_to admin_expense_path(expense)
    assert expense.receipt.attached?
    assert expense.pending_review?
  end

  test "un gasto inválido vuelve a mostrar el formulario con errores" do
    assert_no_difference "Expense.count" do
      post admin_expenses_path, params: { expense: {
        description: "", amount: "-1", spent_on: Date.current,
        user_id: users(:pedro).id, household_id: households(:martinez).id
      } }
    end

    assert_response :unprocessable_content
    assert_select ".flash--alert li", minimum: 2
  end

  test "crear un presupuesto con un input month" do
    assert_difference "Budget.count", 1 do
      post admin_budgets_path, params: { budget: {
        household_id: households(:gomez).id, category_id: "", period: "2026-12", amount: "250000"
      } }
    end
    assert_equal Date.new(2026, 12, 1), Budget.order(:id).last.period
  end

  test "el rol se asigna solo con valores válidos" do
    post admin_users_path, params: { user: {
      name: "Nuevo Admin", email_address: "nuevo@example.com", role: "admin",
      password: "password123", password_confirmation: "password123"
    } }
    assert User.find_by!(email_address: "nuevo@example.com").admin?

    patch admin_user_path(users(:lucia)), params: { user: { name: "Lucía M.", role: "superuser" } }
    assert users(:lucia).reload.member?
  end

  test "el administrador no puede eliminarse a sí mismo" do
    assert_no_difference "User.count" do
      delete admin_user_path(users(:admin))
    end
  end

  test "agregar y quitar un miembro de un hogar" do
    household = households(:gomez)

    assert_difference "household.memberships.count", 1 do
      post admin_household_memberships_path(household), params: { membership: { user_id: users(:diego).id, role: "member" } }
    end

    membership = household.memberships.find_by!(user: users(:diego))
    assert_difference "household.memberships.count", -1 do
      delete admin_household_membership_path(household, membership)
    end
  end

  test "avisar un vencimiento por email" do
    assert_emails 2 do
      post notify_admin_reminder_path(reminders(:visa))
    end
    assert_redirected_to admin_reminders_path
  end
end
