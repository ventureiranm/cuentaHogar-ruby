module Admin
  class DashboardController < BaseController
    def show
      @month = Date.current
      @expenses_total = Expense.in_month(@month).sum(:amount)
      @incomes_total = Income.in_month(@month).sum(:amount)
      @pending_review_count = Expense.pending_review.count
      @users_count = User.count
      @latest_expenses = Expense.includes(:user, :household, :category).recent_first.limit(8)
      @upcoming_reminders = Reminder.pending.includes(:household)
                                    .where(due_on: ..(Date.current + 14)).chronological.limit(6)
      @summaries = Household.ordered.map { |household| household.summary_for(@month) }
    end
  end
end
