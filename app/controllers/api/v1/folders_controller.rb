class Api::V1::FoldersController < ApplicationController
  before_action :set_folder, only: [:show, :jobseekers, :jobseeker_folders, :update, :destroy]

  # GET /folders
  # GET /folders.json
  def index
    # @folders = Folder.first_level
    @folders = @current_user.accessable_folders.first_level.paginate(page: params[:page])
    render json: @folders, meta: pagination_meta(@folders)
  end

  # GET /folders/1
  # GET /folders/1.json
  def show
    render json: @folder, serializer: FolderDetailsSerializer, root: :folder
  end

  # GET /folders/all_jobseekers
  def all_jobseekers
    params[:q] ||= {}
    folder_search = {}
    folder_search[:id_in] = params[:q][:folder_id_in]

    if params[:q][:hash_tags_id_in] || params[:q][:hash_tags_id_eq]
      @q = Jobseeker.where(id: JobseekerFolder.where(folder_id: @current_user.accessable_folders.ransack(folder_search).result.pluck(:id)).pluck(:jobseeker_id)).joins(:hash_tags).ransack(params[:q])
    else
      @q = Jobseeker.where(id: JobseekerFolder.where(folder_id: @current_user.accessable_folders.ransack(folder_search).result.pluck(:id)).pluck(:jobseeker_id)).ransack(params[:q])
    end

    @jobseekers = @q.result(distinct: true).paginate(page: params[:page])
    render json: @jobseekers, meta: pagination_meta(@jobseekers), each_serializer: JobseekerListSerializer, root: :jobseekers
  end

  # GET /folders/1/jobseekers
  # GET /folders/1/jobseekers.json
  def jobseekers
    params[:q] ||= {}
    @q = @folder.jobseekers.ransack(params[:q])
    @jobseekers = @q.result(distinct: true).paginate(page: params[:page])
    render json: @jobseekers, meta: pagination_meta(@jobseekers), each_serializer: JobseekerListSerializer, root: :jobseekers
  end

  # GET /folders/1/jobseeker_folders
  # GET /folders/1/jobseeker_folders.json
  def jobseeker_folders
    params[:q] ||= {}
    @q = @folder.jobseeker_folders.ransack(params[:q])
    @jobseeker_folders = @q.result(distinct: true).includes(:user).paginate(page: params[:page])
    render json: @jobseeker_folders, meta: pagination_meta(@jobseeker_folders).merge!(folder_details: get_current_folder_details), root: :jobseeker_folders
  end

  # GET /folders/1/sub_folders
  # GET /folders/1/sub_folders.json
  def sub_folders
    params[:q] ||= {}
    @q = @folder.sub_folders.ransack(params[:q])
    @sub_folders = @q.result.paginate(page: params[:page])
    render json: @sub_folders, meta: pagination_meta(@sub_folders).merge!(folder_details: get_current_folder_details)
  end

  # POST /folders
  # POST /folders.json
  def create
    @folder = Folder.new(folder_params)

    if @folder.save
      render json: @folder, serializer: FolderDetailsSerializer, root: :folder
    else
      render json: @folder.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /folders/1
  # PATCH/PUT /folders/1.json
  def update
    if @folder.update(folder_params)
      render json: @folder, serializer: FolderDetailsSerializer, root: :folder
    else
      render json: @folder.errors, status: :unprocessable_entity
    end
  end

  # DELETE /folders/1
  # DELETE /folders/1.json
  def destroy
    @folder.destroy
    render nothing: true, status: :no_content
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_folder
      @folder = Folder.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def folder_params
      params[:folder][:creator_id] = @current_user.id if params[:folder] && params[:folder][:creator_id]
      if params[:folder] && params[:folder][:assigned_user_ids]
        params[:folder][:assigned_user_ids] << @current_user.id
        params[:folder][:assigned_user_ids] = params[:folder][:assigned_user_ids].uniq
      end
      params.require(:folder).permit(:name, :description, :parent_id, assigned_user_ids: []).merge!({creator_id: @current_user.id})
      # params[:folder][:user_ids] << @current_user.id if params[:folder] && params[:folder][:user_ids]
      # params.require(:folder).permit(:name, :description, :parent_id, user_ids: []).merge!({creator_id: @current_user.id})
    end

    def get_current_folder_details
      {
          id: @folder.id,
          name: @folder.name,
          level: @folder.level,
          ancestors: @folder.ancestors.reverse.map{|folder| {id: folder.id, name: folder.name}}
      }
    end
end
