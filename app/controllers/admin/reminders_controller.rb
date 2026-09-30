module Admin
  class RemindersController < BaseController
    before_action :set_reminder, only: %i[ edit update destroy notify ]
    before_action :load_households, only: %i[ new create edit update ]

    def index
      @reminders = Reminder.includes(:household).chronological
      @reminders = params[:status] == "paid" ? @reminders.paid : @reminders.pending
    end

    def new
      @reminder = Reminder.new(due_on: Date.current + 7)
    end

    def create
      @reminder = Reminder.new(reminder_params)
      @reminder.user = Current.user

      if @reminder.save
        redirect_to admin_reminders_path, notice: "Vencimiento creado."
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
    end

    def update
      if @reminder.update(reminder_params)
        redirect_to admin_reminders_path, notice: "Vencimiento actualizado."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @reminder.destroy!
      redirect_to admin_reminders_path, notice: "Vencimiento eliminado.", status: :see_other
    end

    # Envía el email de aviso a todos los miembros del hogar.
    def notify
      @reminder.notify_members!
      redirect_to admin_reminders_path,
                  notice: "Aviso enviado a #{@reminder.household.members.count} miembro(s) de #{@reminder.household.name}."
    end

    private
      def set_reminder
        @reminder = Reminder.find(params[:id])
      end

      def load_households
        @households = Household.ordered
      end

      def reminder_params
        params.expect(reminder: [ :household_id, :title, :amount, :due_on, :paid ])
      end
  end
end
