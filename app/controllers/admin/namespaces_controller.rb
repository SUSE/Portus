class Admin::NamespacesController < Admin::BaseController
  def index
    @special_namespaces = Namespace.where(global: true).page(params[:special_page])
    @namespaces = Namespace.where(global: false).page(params[:page])
  end
end
