# HealthController contains endpoints that are relevant for checking the status
# of either portus, or of the components relevant to it.
class HealthController < ActionController::Base
  protect_from_forgery with: :exception

  # Simple ping.
  def index
    render nothing: true, status: 200
  end

  # Renders a JSON with the status of each component.
  def health
    response, success = ::Portus::Health.check
    render json: response, status: success ? :ok : :service_unavailable
  end
end
