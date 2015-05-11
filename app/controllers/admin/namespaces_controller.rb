class Admin::NamespacesController < Admin::BaseController
  def index
    @namespaces = Namespace.all
    render template: 'namespaces/index'
  end
end
