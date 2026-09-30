module Admin
  class BudgetsController < BaseController
    before_action :set_budget, only: %i[ edit update destroy ]
    before_action :load_form_collections, only: %i[ new create edit update ]

    def index
      @budgets = Budget.includes(:household, :category).chronological.order(:household_id, :category_id)
    end

    def new
      @budget = Budget.new(period: Date.current)
    end

    def create
      @budget = Budget.new(budget_params)

      if @budget.save
        redirect_to admin_budgets_path, notice: "Presupuesto creado."
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
    end

    def update
      if @budget.update(budget_params)
        redirect_to admin_budgets_path, notice: "Presupuesto actualizado."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @budget.destroy!
      redirect_to admin_budgets_path, notice: "Presupuesto eliminado.", status: :see_other
    end

    private
      def set_budget
        @budget = Budget.find(params[:id])
      end

      def load_form_collections
        @households = Household.ordered
        @categories = Category.includes(:household).ordered
      end

      def budget_params
        params.expect(budget: [ :household_id, :category_id, :period, :amount ])
      end
  end
end
