module Admin
  class CategoriesController < BaseController
    before_action :set_category, only: %i[ edit update destroy ]
    before_action :load_households, only: %i[ new create edit update ]

    def index
      @categories = Category.includes(:household).order(:household_id, :name)
      @expense_counts = Expense.group(:category_id).count
    end

    def new
      @category = Category.new(color: "#2F4F4A")
    end

    def create
      @category = Category.new(category_params)

      if @category.save
        redirect_to admin_categories_path, notice: "Categoría creada."
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
    end

    def update
      if @category.update(category_params)
        redirect_to admin_categories_path, notice: "Categoría actualizada."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @category.destroy!
      redirect_to admin_categories_path, notice: "Categoría eliminada. Sus gastos quedaron pendientes de revisión.",
                                         status: :see_other
    end

    private
      def set_category
        @category = Category.find(params[:id])
      end

      def load_households
        @households = Household.ordered
      end

      def category_params
        params.expect(category: [ :name, :color, :household_id ])
      end
  end
end
