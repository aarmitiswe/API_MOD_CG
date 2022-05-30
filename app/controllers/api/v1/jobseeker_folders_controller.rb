class Api::V1::JobseekerFoldersController < ApplicationController
  before_action :set_jobseeker_folder, only: [:show, :edit, :update, :destroy]

  # GET /jobseeker_folders
  # GET /jobseeker_folders.json
  def index
    @jobseeker_folders = JobseekerFolder.all
    render json: @jobseeker_folders
  end

  # GET /jobseeker_folders/1
  # GET /jobseeker_folders/1.json
  def show
    render json: @jobseeker_folder
  end

  # POST /jobseeker_folders
  # POST /jobseeker_folders.json
  def create
    @jobseeker_folder = JobseekerFolder.new(jobseeker_folder_params)

    if @jobseeker_folder.save
      render json: @jobseeker_folder
    else
      render json: @jobseeker_folder.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /jobseeker_folders/1
  # PATCH/PUT /jobseeker_folders/1.json
  def update
    if @jobseeker_folder.update(jobseeker_folder_params)
      render json: @jobseeker_folder
    else
      render json: @jobseeker_folder.errors, status: :unprocessable_entity
    end
  end

  # DELETE /jobseeker_folders/1
  # DELETE /jobseeker_folders/1.json
  def destroy
    @jobseeker_folder.destroy
    render nothing: true, status: :no_content
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_jobseeker_folder
      @jobseeker_folder = JobseekerFolder.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def jobseeker_folder_params
      params.require(:jobseeker_folder).permit(:jobseeker_id, :folder_id)
    end
end
