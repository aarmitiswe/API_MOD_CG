class Api::V1::MetaTagsController < ApplicationController
  skip_before_action :authenticate_user
  before_action :set_meta_tag, only: [:show, :edit, :update, :destroy]

  # GET /meta_tags
  # GET /meta_tags.json
  def index
    @meta_tags = MetaTag.all
  end

  # GET /meta_tags/1
  # GET /meta_tags/1.json
  def show
  end

  # GET /meta_tags/new
  def new
    @meta_tag = MetaTag.new
  end

  # GET /meta_tags/1/edit
  def edit
  end

  # POST /meta_tags
  # POST /meta_tags.json
  def create
    @meta_tag = MetaTag.new(meta_tag_params)

    respond_to do |format|
      if @meta_tag.save
        format.html { redirect_to @meta_tag, notice: 'Meta tag was successfully created.' }
        format.json { render :show, status: :created, location: @meta_tag }
      else
        format.html { render :new }
        format.json { render json: @meta_tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /meta_tags/1
  # PATCH/PUT /meta_tags/1.json
  def update
    respond_to do |format|
      if @meta_tag.update(meta_tag_params)
        format.html { redirect_to @meta_tag, notice: 'Meta tag was successfully updated.' }
        format.json { render :show, status: :ok, location: @meta_tag }
      else
        format.html { render :edit }
        format.json { render json: @meta_tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /meta_tags/1
  # DELETE /meta_tags/1.json
  def destroy
    @meta_tag.destroy
    respond_to do |format|
      format.html { redirect_to meta_tags_url, notice: 'Meta tag was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_meta_tag
      @meta_tag = MetaTag.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def meta_tag_params
      params.require(:meta_tag).permit(:name, :description, :page_id)
    end
end
