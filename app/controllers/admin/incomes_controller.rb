module Admin
  class IncomesController < BaseController
    before_action :set_income, only: %i[ edit update destroy ]
    before_action :load_form_collections, only: %i[ new create edit update ]

    def index
      @incomes = Income.includes(:user, :household).recent_first.limit(200)
    end

    def new
      @income = Income.new(received_on: Date.current)
    end

    def create
      @income = Income.new(income_params)

      if @income.save
        redirect_to admin_incomes_path, notice: "Ingreso registrado."
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
    end

    def update
      if @income.update(income_params)
        redirect_to admin_incomes_path, notice: "Ingreso actualizado."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @income.destroy!
      redirect_to admin_incomes_path, notice: "Ingreso eliminado.", status: :see_other
    end

    private
      def set_income
        @income = Income.find(params[:id])
      end

      def load_form_collections
        @users = User.ordered
        @households = Household.ordered
      end

      def income_params
        params.expect(income: [ :description, :amount, :received_on, :user_id, :household_id ])
      end
  end
end
