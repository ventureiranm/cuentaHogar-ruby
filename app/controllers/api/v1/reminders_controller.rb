module Api
  module V1
    class RemindersController < BaseController
      before_action :set_reminder, only: %i[ update pay ]

      # GET /api/v1/reminders?household_id=1&status=pending|paid|overdue&days=15
      def index
        scope = Reminder.where(household_id: current_user.household_ids).includes(:household).chronological
        scope = scope.where(household_id: params[:household_id]) if params[:household_id].present?
        @reminders = filter_by_status(scope).limit(limit_param)
      end

      # POST /api/v1/reminders  { "reminder": { "household_id", "title", "amount", "due_on" } }
      def create
        household = find_household!(params.expect(reminder: [ :household_id ])[:household_id])
        @reminder = household.reminders.new(reminder_params)
        @reminder.user = current_user

        if @reminder.save
          render :show, status: :created
        else
          render_errors(@reminder)
        end
      end

      # PATCH /api/v1/reminders/:id
      def update
        if @reminder.update(reminder_params)
          render :show
        else
          render_errors(@reminder)
        end
      end

      # PATCH /api/v1/reminders/:id/pay
      def pay
        @reminder.mark_as_paid!
        render :show
      end

      private
        def set_reminder
          @reminder = Reminder.where(household_id: current_user.household_ids).find(params[:id])
        end

        def reminder_params
          params.expect(reminder: [ :title, :amount, :due_on ])
        end

        def filter_by_status(scope)
          case params[:status]
          when "paid" then scope.paid
          when "overdue" then scope.overdue
          when "all" then scope
          else
            params[:days].present? ? scope.due_within(params[:days].to_i.clamp(0, 365)) : scope.pending
          end
        end
    end
  end
end
