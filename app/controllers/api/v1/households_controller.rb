module Api
  module V1
    class HouseholdsController < BaseController
      before_action :set_household, only: %i[ show summary ]

      # GET /api/v1/households
      def index
        @households = current_user.households.includes(memberships: :user).ordered
      end

      # GET /api/v1/households/:id
      def show
      end

      # POST /api/v1/households  { "household": { "name", "currency" } }
      # Quien lo crea queda como owner.
      def create
        @household = Household.new(params.expect(household: [ :name, :currency ]))
        @household.memberships.build(user: current_user, role: :owner)

        if @household.save
          render :show, status: :created
        else
          render_errors(@household)
        end
      end

      # GET /api/v1/households/:id/summary?month=2026-09
      def summary
        render json: @household.summary_for(month_param).to_h
      end

      private
        def set_household
          @household = find_household!(params[:id])
        end
    end
  end
end
