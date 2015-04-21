class ImagesController < ApplicationController

  # GET /images
  # GET /images.json
  def index
    @images = Image.all

    respond_with(@images)
  end

  # GET /images/1
  # GET /images/1.json
  def show
    @image = Image.find(params[:id])

    respond_with(@image)
  end
end
