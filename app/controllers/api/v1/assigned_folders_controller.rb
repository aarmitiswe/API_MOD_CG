class Api::V1::AssignedFoldersController < ApplicationController
  before_action :set_assigned_folder, only: [:show, :edit, :update, :destroy]

  # GET /assigned_folders
  # GET /assigned_folders.json
  def index
    @assigned_folders = AssignedFolder.all
    render json: @assigned_folders
  end

  # GET /assigned_folders/1
  # GET /assigned_folders/1.json
  def show
    render json: @assigned_folder
  end
  # POST /assigned_folders
  # POST /assigned_folders.json
  def create
    @assigned_folder = AssignedFolder.new(assigned_folder_params)
    if @assigned_folder.save
      render json: @assigned_folder
    else
      render json: @assigned_folder.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /assigned_folders/1
  # PATCH/PUT /assigned_folders/1.json
  def update
    if @assigned_folder.update(assigned_folder_params)
      render json: @assigned_folder
    else
      render json: @assigned_folder.errors, status: :unprocessable_entity
    end
  end

  # DELETE /assigned_folders/1
  # DELETE /assigned_folders/1.json
  def destroy
    @assigned_folder.destroy
    render nothing: true, status: :no_content
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_assigned_folder
      @assigned_folder = AssignedFolder.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def assigned_folder_params
      params.require(:assigned_folder).permit(:user_id, :folder_id)
    end
end
