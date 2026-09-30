module Api
  module V1
    class ExpensesController < BaseController
      before_action :set_expense, only: %i[ show update destroy ]

      # GET /api/v1/expenses?household_id=1|scope=personal&month=2026-09&category_id=2&pending=true&limit=20
      def index
        @expenses = Expense.visible_to(current_user)
                           .includes(:user, :household, :category, receipt_attachment: :blob)
                           .recent_first
        @expenses = apply_filters(@expenses).limit(limit_param)
      end

      # GET /api/v1/expenses/:id
      def show
      end

      # POST /api/v1/expenses (JSON o multipart/form-data si se adjunta expense[receipt])
      def create
        @expense = current_user.expenses.new(expense_params)

        if @expense.save
          render :show, status: :created
        else
          render_errors(@expense)
        end
      end

      # PATCH /api/v1/expenses/:id
      def update
        if @expense.update(expense_params)
          render :show
        else
          render_errors(@expense)
        end
      end

      # DELETE /api/v1/expenses/:id
      def destroy
        @expense.destroy!
        head :no_content
      end

      private
        def set_expense
          @expense = Expense.visible_to(current_user).find(params[:id])
        end

        def expense_params
          params.expect(expense: [ :description, :amount, :spent_on, :household_id,
                                   :category_id, :recurring, :notes, :receipt ])
        end

        def apply_filters(scope)
          scope = scope.personal if params[:scope] == "personal"
          scope = scope.where(household_id: params[:household_id]) if params[:household_id].present?
          scope = scope.where(category_id: params[:category_id]) if params[:category_id].present?
          scope = scope.in_month(month_param) if params[:month].present?
          scope = scope.pending_review if params[:pending] == "true"
          scope
        end
    end
  end
end
