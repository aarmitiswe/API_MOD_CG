class Api::V1::Job2RequestsController < ApplicationController
  before_action :set_job_request, only: [:show, :edit, :update, :destroy]

  # GET /job_requests
  # GET /job_requests.json
  def index
    @job_requests = JobRequest.all
    render json: @job_requests
  end

  # GET /job_requests/1
  # GET /job_requests/1.json
  def show
    render json: @job_request
  end

  # POST /job_requests
  # POST /job_requests.json
  # @cleve: status_approval_one sent/approve/reject/nil & Same for two/three/four/five
  def create
    @job_request = JobRequest.new(job_request_params)

    if @job_request.save
      render json: @job_request
    else
      render json: @job_request.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /job_requests/1
  # PATCH/PUT /job_requests/1.json
  # @Cleve: Here the main method .. send request with the new status of each user.
  # Here you'll change the status of each approver.
  def update
    if @job_request.update(job_request_params)
      render json: @job_request
    else
      render json: @job_request.errors, status: :unprocessable_entity
    end
  end

  # DELETE /job_requests/1
  # DELETE /job_requests/1.json
  def destroy
    @job_request.destroy
    render nothing: true, status: :no_content
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_job_request
      @job_request = JobRequest.find_by_id(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def job_request_params
      params.require(:job_request).permit(:job_id, :hiring_manager_id, :total_number_vacancies, :status_approval_one,
                                          :status_approval_two, :status_approval_three, :status_approval_four,
                                          :status_approval_five)
    end
end
