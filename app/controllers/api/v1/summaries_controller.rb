module Api
  module V1
    class SummariesController < BaseController
      # GET /api/v1/summary?month=2026-09
      # Resumen del ámbito Personal: gastos e ingresos del usuario sin hogar.
      # Mismos campos que /api/v1/households/:id/summary, con household_id null.
      def show
        render json: MonthlySummary.personal(current_user, month_param).to_h
      end
    end
  end
end
