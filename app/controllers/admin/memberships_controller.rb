module Admin
  class MembershipsController < BaseController
    before_action :set_household

    def create
      membership = @household.memberships.new(params.expect(membership: [ :user_id ]))
      role = params.dig(:membership, :role).to_s
      membership.role = role if Membership.roles.key?(role)

      if membership.save
        redirect_to admin_household_path(@household), notice: "Miembro agregado."
      else
        redirect_to admin_household_path(@household), alert: membership.errors.full_messages.to_sentence
      end
    end

    def destroy
      @household.memberships.find(params[:id]).destroy!
      redirect_to admin_household_path(@household), notice: "Miembro quitado del hogar.", status: :see_other
    end

    private
      def set_household
        @household = Household.find(params[:household_id])
      end
  end
end
