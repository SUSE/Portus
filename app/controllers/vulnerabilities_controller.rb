class VulnerabilitiesController < ApplicationController
  before_action :set_repository
  respond_to :json

  def index
    response = {}
    @repository.tags.each do |tag|
      sec = ::Portus::Security.new(@repository.full_name, tag.name)
      response[tag.name] = sec.vulnerabilities
    end

    render json: response.to_json
  end

  private

  def set_repository
    @repository = Repository.find(params[:repository_id])
  end
end
