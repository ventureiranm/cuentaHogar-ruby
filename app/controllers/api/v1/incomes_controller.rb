module Api
  module V1
    class IncomesController < BaseController
      before_action :set_income, only: %i[ show update destroy ]

      # GET /api/v1/incomes?household_id=1|scope=personal&month=2026-09
      def index
        @incomes = Income.visible_to(current_user).includes(:user, :household).recent_first
        @incomes = @incomes.personal if params[:scope] == "personal"
        @incomes = @incomes.where(household_id: params[:household_id]) if params[:household_id].present?
        @incomes = @incomes.in_month(month_param) if params[:month].present?
        @incomes = @incomes.limit(limit_param)
      end

      def show
      end

      def create
        @income = current_user.incomes.new(income_params)

        if @income.save
          render :show, status: :created
        else
          render_errors(@income)
        end
      end

      def update
        if @income.update(income_params)
          render :show
        else
          render_errors(@income)
        end
      end

      def destroy
        @income.destroy!
        head :no_content
      end

      private
        def set_income
          @income = Income.visible_to(current_user).find(params[:id])
        end

        def income_params
          params.expect(income: [ :description, :amount, :received_on, :household_id ])
        end
    end
  end
end
