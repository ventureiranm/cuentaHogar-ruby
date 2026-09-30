module Api
  module V1
    # Base de la API pública. Hereda de ActionController::API (no usa cookies ni
    # la sesión del back-office): el usuario final se autentica con un token
    # en el header `Authorization: Bearer <token>`.
    class BaseController < ActionController::API
      include ActionController::HttpAuthentication::Token::ControllerMethods

      before_action :authenticate_api_user!

      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
      rescue_from ActiveRecord::RecordInvalid, with: :render_record_invalid
      rescue_from ActionController::ParameterMissing, with: :render_bad_request

      private
        attr_reader :current_api_token

        def current_user
          current_api_token&.user
        end

        def authenticate_api_user!
          @current_api_token = authenticate_with_http_token do |token, _options|
            ApiToken.authenticate(token)
          end
          return if @current_api_token

          response.headers["WWW-Authenticate"] = 'Bearer realm="CuentaHogar"'
          render json: { errors: [ "Token inválido, vencido o ausente" ] }, status: :unauthorized
        end

        def render_errors(record_or_messages, status: :unprocessable_content)
          messages = if record_or_messages.respond_to?(:errors)
            record_or_messages.errors.full_messages
          else
            Array(record_or_messages)
          end
          render json: { errors: messages }, status: status
        end

        def render_not_found(_exception = nil)
          render json: { errors: [ "Recurso no encontrado" ] }, status: :not_found
        end

        def render_record_invalid(exception)
          render_errors(exception.record)
        end

        def render_bad_request(exception)
          render json: { errors: [ exception.message ] }, status: :bad_request
        end

        # ?month=2026-09 → Date. Si no viene o es inválido, el mes actual.
        def month_param
          Date.strptime(params[:month].to_s, "%Y-%m")
        rescue Date::Error
          Date.current
        end

        # Límite de resultados para los listados (?limit=20, máx. 200).
        def limit_param
          params.fetch(:limit, 50).to_i.clamp(1, 200)
        end

        def find_household!(id)
          current_user.households.find(id)
        end
    end
  end
end
