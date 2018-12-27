# frozen_string_literal: true

# Allows the creation of exactly one registry. It also allows updating the
# "use_ssl" attribute of a given registry. Doing all this is safe because only
# admin users will be able to reach this controller.
class Admin::RegistriesController < Admin::BaseController
  before_action :registry_created, only: %i[new create]

  # GET /admin/registries/
  def index
    @registries = Registry.all

    redirect_to new_admin_registry_url if Registry.none?
  end

  # GET /admin/registries/new
  def new
    @registry = Registry.new
  end

  # POST /admin/registries
  #
  # This method checks whether the given registry is reachable or not. If it
  # is not, then it will redirect back to the :new page asking for
  # confirmation. If the :force parameter is passed, then this check is not
  # done. If this check is passed/skipped, then it will try to create the
  # registry.
  def create
    svc = ::Registries::CreateService.new(current_user, create_params)
    svc.force = params[:force]
    svc.execute

    if svc.valid?
      redirect_to admin_registries_path, notice: "Registry was successfully created."
    elsif svc.reachable?
      flash[:alert] = svc.messages
      redirect_to new_admin_registry_path, alert: svc.messages
    else
      flash[:alert] = svc.messages
      render :new, status: :unprocessable_entity
    end
  end

  # GET /admin/registries/:id/edit
  #
  # Note that the admin will only be able to edit the hostname if there are no
  # repositories.
  def edit
    @can_change_hostname = Repository.none?
    @registry            = Registry.find(params[:id])
    @registry_serialized = API::Entities::Registries.represent(
      @registry,
      current_user: current_user
    ).to_json
  end

  # PUT /admin/registries/1
  #
  # Right now this just toggles the value of the "use_ssl" attribute for the
  # given registry. This might change in the future.
  def update
    attrs = update_params.merge(id: params[:id])
    svc = ::Registries::UpdateService.new(current_user, attrs)
    @registry = svc.execute

    if svc.valid?
      # NOTE: if we decide to use rails-observers at some point,
      # we can remove this from here and use it in observers
      Rails.cache.delete "registry#{@registry.id}_status"
      redirect_to admin_registries_path, notice: "Registry updated successfully!"
    else
      flash[:alert] = svc.messages
      @can_change_hostname = Repository.none?
      render "edit", status: :unprocessable_entity
    end
  end

  private

  # Raises a routing error if there is already a registry in place.
  # NOTE: (mssola) remove this once we support multiple registries.
  def registry_created
    raise ActionController::RoutingError, "Not found" if Registry.any?
  end

  # The required/permitted parameters on the create method.
  def create_params
    params.require(:registry).permit(:name, :hostname, :use_ssl, :external_hostname)
  end

  # The required/permitted parameters on update. The hostname parameter will be
  # allowed depending whether there are repositories already created or not.
  def update_params
    permitted = [:name, :use_ssl, (:hostname unless Repository.any?), :external_hostname].compact
    params.require(:registry).permit(permitted)
  end
end
