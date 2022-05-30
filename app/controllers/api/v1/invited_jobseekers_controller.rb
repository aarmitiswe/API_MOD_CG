class Api::V1::InvitedJobseekersController < ApplicationController
  before_action :job_owner

  # POST /invited_jobseekers
  # POST /invited_jobseekers.json
  def create
    @invited_jobseeker = InvitedJobseeker.new(invited_jobseeker_params)

    if @invited_jobseeker.save
      render json: @invited_jobseeker
    else
      render json: @invited_jobseeker.errors, status: :unprocessable_entity
    end
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def invited_jobseeker_params
      params.require(:invited_jobseeker).permit(:jobseeker_id, :job_id, :msg_content)
    end

  def job_owner
    if params[:invited_jobseeker].nil? || params[:invited_jobseeker][:job_id].nil? ||
        !@current_company.jobs.pluck(:id).include?(params[:invited_jobseeker][:job_id].to_i)
      @current_ability.cannot params[:action].to_sym, InvitedJobseeker
      authorize!(params[:action].to_sym, InvitedJobseeker)
    end
  end
end
