class Api::V1::PageImagesController < ApplicationController
  skip_before_action :authenticate_user
  before_action :set_page_image, only: [:show, :edit, :update, :destroy]

  # GET /page_images
  # GET /page_images.json
  def index
    @page_images = PageImage.all
    render json: @page_images
  end

  # GET /page_images/1
  # GET /page_images/1.json
  def show
  end

  # GET /page_images/new
  def new
    @page_image = PageImage.new
  end

  # GET /page_images/1/edit
  def edit
  end

  # POST /page_images
  # POST /page_images.json
  def create
    @page_image = PageImage.new(page_image_params)

    respond_to do |format|
      if @page_image.save
        format.html { redirect_to @page_image, notice: 'Page image was successfully created.' }
        format.json { render :show, status: :created, location: @page_image }
      else
        format.html { render :new }
        format.json { render json: @page_image.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /page_images/1
  # PATCH/PUT /page_images/1.json
  def update
    respond_to do |format|
      if @page_image.update(page_image_params)
        format.html { redirect_to @page_image, notice: 'Page image was successfully updated.' }
        format.json { render :show, status: :ok, location: @page_image }
      else
        format.html { render :edit }
        format.json { render json: @page_image.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /page_images/1
  # DELETE /page_images/1.json
  def destroy
    @page_image.destroy
    respond_to do |format|
      format.html { redirect_to page_images_url, notice: 'Page image was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_page_image
      @page_image = PageImage.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def page_image_params
      params.require(:page_image).permit(:page_id, :image_id, :alt)
    end
end
