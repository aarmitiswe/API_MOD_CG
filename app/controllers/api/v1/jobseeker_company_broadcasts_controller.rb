class Api::V1::JobseekerCompanyBroadcastsController < ApplicationController

  # GET /jobseeker_company_broadcasts
  # GET /jobseeker_company_broadcasts.json
  def index
    @jobseeker_company_broadcasts = @current_user.jobseeker.jobseeker_company_broadcasts
    render json: @jobseeker_company_broadcasts
  end

  # POST /jobseeker_company_broadcasts
  # POST /jobseeker_company_broadcasts.json
  def create
    @jobseeker_company_broadcast = @current_user.jobseeker.jobseeker_company_broadcasts.new(jobseeker_company_broadcast_params)

    if @jobseeker_company_broadcast.save
      render json: @jobseeker_company_broadcast
    else
      render json: @jobseeker_company_broadcast.errors, status: :unprocessable_entity
    end
  end

  def create_bulk
    response = JobseekerCompanyBroadcast.create_bulk(params[:jobseeker_company_broadcast][:company_ids], @current_user.jobseeker, params[:jobseeker_company_broadcast][:duplicate])
    if response.kind_of?(Array)
      render json: response
    else
      if response == 'has_duplicate'
        render json: { errors: [{company_ids: "duplicate"}]}, status: :unprocessable_entity
      else
        render json: { errors: [{company_ids: "greater than remaining credits"}] }, status: :unprocessable_entity

      end
    end
    # if params[:jobseeker_company_broadcast][:duplicate] && @jobseeker_company_broadcasts = JobseekerCompanyBroadcast.create(params[:jobseeker_company_broadcast][:company_ids].map{|company_id| {
    #     company_id: company_id,
    #     jobseeker_id: @current_user.jobseeker.id,
    #     package_broadcast_id: params[:jobseeker_company_broadcast][:package_broadcast_id]
    # } })
    #   render json: @jobseeker_company_broadcasts
    # else
    #   render json: @jobseeker_company_broadcasts.reject{ |company_broadcast| company_broadcast.errors.blank? }, status: :unprocessable_entity
    # end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def jobseeker_company_broadcast_params
      params.require(:jobseeker_company_broadcast).permit(:company_id, :status)
    end
end
