module Admin
  class UsersController < BaseController
    before_action :set_user, only: %i[ show edit update destroy ]

    def index
      @users = User.includes(:households).ordered
    end

    def show
      @memberships = @user.memberships.includes(:household)
      @expenses_count = @user.expenses.count
    end

    def new
      @user = User.new
    end

    def create
      @user = User.new(user_params)
      assign_role

      if @user.save
        redirect_to admin_user_path(@user), notice: "Usuario creado."
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
    end

    def update
      @user.assign_attributes(user_params)
      assign_role

      if @user.save
        redirect_to admin_user_path(@user), notice: "Usuario actualizado."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      if @user == Current.user
        redirect_to admin_users_path, alert: "No podés eliminar tu propio usuario."
      else
        @user.destroy!
        redirect_to admin_users_path, notice: "Usuario eliminado.", status: :see_other
      end
    end

    private
      def set_user
        @user = User.find(params[:id])
      end

      def user_params
        params.expect(user: [ :name, :email_address, :password, :password_confirmation ])
      end

      # El rol se asigna aparte (y solo con valores válidos) para no exponerlo a mass assignment.
      def assign_role
        role = params.dig(:user, :role).to_s
        @user.role = role if User.roles.key?(role)
      end
  end
end
