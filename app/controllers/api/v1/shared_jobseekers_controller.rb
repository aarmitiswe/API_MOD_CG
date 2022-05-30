class Api::V1::SharedJobseekersController < ApplicationController
  before_action :set_shared_jobseeker, only: [:show, :update, :destroy]

  # GET /shared_jobseekers
  # GET /shared_jobseekers.json
  def index
    @q = SharedJobseeker.ransack(params[:q])
    @shared_jobseekers = @q.result.paginate(page: params[:page])
    render json: @shared_jobseekers, meta: pagination_meta(@shared_jobseekers), each_serializer: SharedJobseekerSerializer, ar: params[:ar]
  end

  # GET /shared_jobseekers/1
  # GET /shared_jobseekers/1.json
  def show
    render json: @shared_jobseeker
  end

  # POST /shared_jobseekers
  # POST /shared_jobseekers.json
  def create
    @shared_jobseeker = SharedJobseeker.new(shared_jobseeker_params)

    if @shared_jobseeker.save
      render json: @shared_jobseeker
    else
      render json: @shared_jobseeker.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /shared_jobseekers/1
  # PATCH/PUT /shared_jobseekers/1.json
  def update
    if @shared_jobseeker.update(shared_jobseeker_params)
      render json: @shared_jobseeker
    else
      render json: @shared_jobseeker.errors, status: :unprocessable_entity
    end
  end

  # DELETE /shared_jobseekers/1
  # DELETE /shared_jobseekers/1.json
  def destroy
    @shared_jobseeker.destroy
    render nothing: true, status: :no_content
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_shared_jobseeker
      @shared_jobseeker = SharedJobseeker.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def shared_jobseeker_params
      params.require(:shared_jobseeker).permit(:sender_id, :receiver_id, :jobseeker_id)
    end
end
