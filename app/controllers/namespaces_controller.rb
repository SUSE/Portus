class NamespacesController < ApplicationController

  # GET /namespaces
  # GET /namespaces.json
  def index
    @namespaces = Namespace.all

    respond_with(@namespaces)
  end

  # GET /namespaces/1
  # GET /namespaces/1.json
  def show
    @namespace = Namespace.find(params[:id])

    respond_with(@namespace)
  end
end
