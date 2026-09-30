module Admin
  class ExpensesController < BaseController
    before_action :set_expense, only: %i[ show edit update destroy ]
    before_action :load_form_collections, only: %i[ new create edit update ]

    def index
      @households = Household.ordered
      @expenses = Expense.includes(:user, :household, :category).recent_first
      @expenses = @expenses.where(household_id: params[:household_id]) if params[:household_id].present?
      @expenses = @expenses.pending_review if params[:pending] == "1"
      @expenses = @expenses.limit(200)
    end

    def show
    end

    def new
      @expense = Expense.new(spent_on: Date.current)
    end

    def create
      @expense = Expense.new(expense_params)

      if @expense.save
        redirect_to admin_expense_path(@expense), notice: "Gasto creado."
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
    end

    def update
      if @expense.update(expense_params)
        redirect_to admin_expense_path(@expense), notice: "Gasto actualizado."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @expense.destroy!
      redirect_to admin_expenses_path, notice: "Gasto eliminado.", status: :see_other
    end

    private
      def set_expense
        @expense = Expense.find(params[:id])
      end

      def load_form_collections
        @users = User.ordered
        @households = Household.ordered
        @categories = Category.includes(:household).ordered
      end

      def expense_params
        params.expect(expense: [ :description, :amount, :spent_on, :user_id, :household_id,
                                 :category_id, :recurring, :source, :notes, :receipt ])
      end
  end
end
