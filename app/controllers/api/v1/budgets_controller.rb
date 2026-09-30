module Api
  module V1
    class BudgetsController < BaseController
      # GET /api/v1/budgets?household_id=1&month=2026-09
      def index
        household = find_household!(params.require(:household_id))
        @budgets = household.budgets.for_month(month_param).includes(:category).order(:category_id)
      end

      # POST /api/v1/budgets  { "budget": { "household_id", "category_id", "period": "2026-09", "amount" } }
      def create
        household = find_household!(params.expect(budget: [ :household_id ])[:household_id])
        @budget = household.budgets.new(params.expect(budget: [ :category_id, :period, :amount ]))

        if @budget.save
          render :show, status: :created
        else
          render_errors(@budget)
        end
      end
    end
  end
end
