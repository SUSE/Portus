# frozen_string_literal: true

# Creates a new registry with the given parameters. This method assumes that the
# database is ready and that there is no registry setup already.
def create_registry!(params)
  svc = ::Registries::CreateService.new(nil, params)
  svc.execute
  return unless svc.valid?

  Rails.logger.tagged("registry") do
    msg = JSON.pretty_generate(params)
    Rails.logger.info "Registry created with the following parameters:\n#{msg}"
  end
end

portus_exists = false
begin
  portus_exists = User.exists?(username: "portus")
rescue StandardError
  # We will ignore any error and skip this initializer. This is done this way
  # because it can get really tricky to catch all the myriad of exceptions that
  # might be raised on database errors.
  portus_exists = false
end

if portus_exists && Registry.none?
  params = {
    name:     ENV["PORTUS_INIT_REGISTRY_NAME"] || "registry",
    hostname: ENV["PORTUS_INIT_REGISTRY_HOSTNAME"] || "",
    use_ssl:  ENV["PORTUS_INIT_REGISTRY_USE_SSL"] || ""
  }

  create_registry!(params) if params[:hostname].present? && params[:use_ssl].present?
end
