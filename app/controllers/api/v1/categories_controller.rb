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
    end
  end
end
