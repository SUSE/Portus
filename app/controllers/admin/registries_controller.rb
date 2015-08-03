class Admin::RegistriesController < Admin::BaseController
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
    if Registry.count > 0
      redirect_to admin_registries_path,
        alert: "No more than one registry is currently supported"
      return
    end

    @registry = Registry.new(registries_params)

    if @registry.save
      Namespace.update_all(registry_id: @registry.id)
      redirect_to admin_registries_path, notice: "Registry was successfully created."
    else
      render :new
    end
  end

  private

  def registries_params
    params.require(:registry).permit(:name, :hostname)
  end
end
