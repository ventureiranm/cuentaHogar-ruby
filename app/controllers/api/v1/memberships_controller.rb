module Api
  module V1
    # Miembros de un hogar. Solo quien tiene rol owner en ese hogar puede agregarlos o quitarlos.
    class MembershipsController < BaseController
      before_action :set_household
      before_action :require_owner

      # POST /api/v1/households/:household_id/memberships  { "email_address": "..." }
      def create
        email = params.require(:email_address).to_s
        user = User.find_by(email_address: email)
        return render_errors([ "No hay ningún usuario registrado con el email #{email.strip}" ], status: :not_found) unless user

        @membership = @household.memberships.new(user: user, role: :member)

        if @membership.save
          render :show, status: :created
        else
          render_errors(@membership)
        end
      end

      # DELETE /api/v1/households/:household_id/memberships/:id
      def destroy
        membership = @household.memberships.find(params[:id])
        if membership.user_id == current_user.id
          return render_errors([ "No podés quitarte a vos mismo/a: sos quien administra este hogar" ])
        end

        membership.destroy!
        head :no_content
      end

      private
        def set_household
          @household = find_household!(params[:household_id])
        end

        def require_owner
          return if @household.memberships.exists?(user: current_user, role: :owner)

          render_errors([ "Solo quien administra el hogar (owner) puede gestionar sus miembros" ], status: :forbidden)
        end
    end
  end
end
