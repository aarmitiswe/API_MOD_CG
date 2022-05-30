class Api::V1::OfferLetterRequestsController < ApplicationController
  before_action :set_offer_letter_request, only: [:show, :update, :destroy]

  # GET /offer_letter_requests
  # GET /offer_letter_requests.json
  def index
    params[:q] ||= {}
    @q = OfferLetterRequest.ransack(params[:q])
    @offer_letter_requests = @q.result
    render json: @offer_letter_requests
  end

  # GET /offer_letter_requests/1
  # GET /offer_letter_requests/1.json
  def show
    render json: @offer_letter_request
  end

  # POST /offer_letter_requests
  # POST /offer_letter_requests.json
  def create
    @offer_letter_request = OfferLetterRequest.new(offer_letter_request_params)

    if params[:offer_letter_request][:job_application_status_change_id]
      @jobseeker_user = JobApplicationStatusChange.find(params[:offer_letter_request][:job_application_status_change_id]).jobseeker
      @jobseeker = @jobseeker_user.jobseeker
    end

    if @offer_letter_request.save
      @offer_letter_request.add_offer_letter @current_user
      render json: @offer_letter_request
    else
      render json: @offer_letter_request.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /offer_letter_requests/1
  # PATCH/PUT /offer_letter_requests/1.json
  def update
    @jobseeker_user = @offer_letter_request.jobseeker_user
    @jobseeker = @jobseeker_user.jobseeker

    if @offer_letter_request.update(offer_letter_request_params)
      @offer_letter_request.add_offer_letter @current_user
      render json: @offer_letter_request
    else
      render json: @offer_letter_request.errors, status: :unprocessable_entity
    end
  end

  # DELETE /offer_letter_requests/1
  # DELETE /offer_letter_requests/1.json
  def destroy
    @offer_letter_request.destroy
    render nothing: true, status: :no_content
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_offer_letter_request
      @offer_letter_request = OfferLetterRequest.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def offer_letter_request_params
      params.require(:offer_letter_request).permit(:basic_salary, :housing_salary, :transportation_salary,
                                                   :mobile_allowance_salary, :total_salary,
                                                   :job_application_status_change_id, :offer_letter_id,
                                                   :offer_letter_type, :status_approval_one,
                                                   :status_approval_two, :status_approval_three,
                                                   :status_approval_four, :status_approval_five,
                                                   :date_approval_one, :date_approval_two, :date_approval_three,
                                                   :date_approval_four, :date_approval_five, :comment_approval_one,
                                                   :comment_approval_two, :comment_approval_three, :comment_approval_four,
                                                   :comment_approval_five, :reply_jobseeker, :status_jobseeker, :end_date,
                                                   :start_date, :job_grade, :title, :relocation_allowance, :joining_date,
                                                   :hiring_manager_id, :candidate_dob, :candidate_second_name, :candidate_third_name,
                                                   :candidate_birth_city, :candidate_birth_country, :candidate_nationality,
                                                   :candidate_religion, :candidate_gender,
                                                   offer_letter_attributes: [:document])
    end
end
