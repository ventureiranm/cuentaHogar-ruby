module Admin
  class HouseholdsController < BaseController
    before_action :set_household, only: %i[ show edit update destroy ]

    def index
      @households = Household.includes(:members).ordered
    end

    def show
      @summary = @household.summary_for(Date.current)
      @memberships = @household.memberships.includes(:user).order(role: :desc)
      @available_users = User.ordered.where.not(id: @household.member_ids)
      @budgets = @household.budgets.for_month(Date.current).includes(:category)
    end

    def new
      @household = Household.new(currency: "ARS")
    end

    def create
      @household = Household.new(household_params)

      if @household.save
        redirect_to admin_household_path(@household), notice: "Hogar creado."
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
    end

    def update
      if @household.update(household_params)
        redirect_to admin_household_path(@household), notice: "Hogar actualizado."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @household.destroy!
      redirect_to admin_households_path, notice: "Hogar eliminado.", status: :see_other
    end

    private
      def set_household
        @household = Household.find(params[:id])
      end

      def household_params
        params.expect(household: [ :name, :currency ])
      end
  end
end
