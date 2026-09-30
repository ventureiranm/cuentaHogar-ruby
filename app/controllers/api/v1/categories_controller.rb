module Api
  module V1
    class CategoriesController < BaseController
      # GET /api/v1/categories?household_id=1
      def index
        household_ids = if params[:household_id].present?
          [ find_household!(params[:household_id]).id ]
        else
          current_user.household_ids
        end
        @categories = Category.available_for(household_ids).ordered
      end

      # POST /api/v1/categories  { "category": { "household_id", "name", "color" } }
      # Siempre es una categoría propia de un hogar del usuario: las globales solo se
      # crean desde el back-office. Sin household_id responde 400; con uno ajeno, 404.
      def create
        household = find_household!(params.require(:category).require(:household_id))
        @category = household.categories.new(params.expect(category: [ :name, :color ]))

        if @category.save
          render :show, status: :created
        else
          render_errors(@category)
        end
      end
    end
  end
end
