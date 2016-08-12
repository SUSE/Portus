class Admin::NamespacesController < Admin::BaseController
  respond_to :html, :js

  def index
    @special_namespaces = Namespace.where(global: true)
    @namespaces = Namespace.not_portus.where(global: false).search(params[:filter]).page(params[:page])
    respond_with(@namespaces)
  end
end
