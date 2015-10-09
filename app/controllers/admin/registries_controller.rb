# Allows the creation of exactly one registry. It also allows updating the
# "use_ssl" attribute of a given registry. Doing all this is safe because only
# admin users will be able to reach this controller.
class Admin::RegistriesController < Admin::BaseController
  before_action :registry_created, only: [:new, :create]

  # GET /admin/registries/
  def index
    @registries = Registry.all
  end

  # GET /admin/registries/new
  def new
    @registry = Registry.new
  end

  # POST /admin/registries
  def create
    @registry = Registry.new(create_params)

    if @registry.save
      Namespace.update_all(registry_id: @registry.id)
      redirect_to admin_registries_path, notice: "Registry was successfully created."
    else
      render :new
    end
  end

  # GET /admin/registries/:id/edit
  #
  # Note that the admin will only be able to edit the hostname if there are no
  # repositories.
  def edit
    @registry            = Registry.find(params[:id])
    @can_change_hostname = !Repository.any?
  end

  # PUT /admin/registries/1
  #
  # Right now this just toggles the value of the "use_ssl" attribute for the
  # given registry. This might change in the future.
  def update
    @registry = Registry.find(params[:id])
    @registry.update_attributes(update_params)
    redirect_to admin_registries_path, flash: { notice: "Registry updated successfully!" }
  end

  private

  # Raises a routing error if there is already a registry in place.
  # NOTE: (mssola) remove this once we support multiple registries.
  def registry_created
    raise ActionController::RoutingError, "Not found" if Registry.count > 0
  end

  # The required/permitted parameters on the create method.
  def create_params
    params.require(:registry).permit(:name, :hostname, :use_ssl)
  end

  # The required/permitted parameters on update. The hostname parameter will be
  # allowed depending whether there are repositories already created or not.
  def update_params
    permitted = [:name, :use_ssl, (:hostname unless Repository.any?)].compact
    params.require(:registry).permit(permitted)
  end
end
