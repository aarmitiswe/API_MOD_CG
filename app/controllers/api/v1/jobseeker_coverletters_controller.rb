class Api::V1::JobseekerCoverlettersController < ApplicationController
  before_action :set_jobseeker
  before_action :set_jobseeker_coverletter, only: [:show, :update, :destroy, :delete_document]
  before_action :jobseeker_owner

  # GET /jobseeker_coverletters
  # GET /jobseeker_coverletters.json
  def index
    @jobseeker_coverletters = @jobseeker.jobseeker_coverletters.order(default: :desc)
    render json: @jobseeker_coverletters
  end

  # GET /jobseeker_coverletters/1
  # GET /jobseeker_coverletters/1.json
  def show
    render json: @jobseeker_coverletter
  end

  # POST /jobseeker_coverletters
  # POST /jobseeker_coverletters.json
  def create
    @jobseeker_coverletter = @jobseeker.jobseeker_coverletters.new(jobseeker_coverletter_params)

    if @jobseeker_coverletter.save
      render json: @jobseeker_coverletter
    else
      render json: @jobseeker_coverletter.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /jobseeker_coverletters/1
  # PATCH/PUT /jobseeker_coverletters/1.json
  def update
    if @jobseeker_coverletter.update(jobseeker_coverletter_params)
      render json: @jobseeker_coverletter
    else
      render json: @jobseeker_coverletter.errors, status: :unprocessable_entity
    end
  end

  # DELETE /jobseeker_coverletters/1
  # DELETE /jobseeker_coverletters/1.json
  def destroy
    @jobseeker_coverletter.destroy
    render nothing: true, status: 204
  end

  def delete_document
    @jobseeker_coverletter.delete_document
    render nothing: true, status: 204
  end

  def delete_bulk
    soft_delete_ids = JobApplication.where(jobseeker_coverletter_id: params[:jobseeker_coverletter_ids]).map(&:jobseeker_coverletter_id)
    JobseekerCoverletter.where(id: soft_delete_ids).update_all(is_deleted: true)
    JobseekerCoverletter.where(id: params[:jobseeker_coverletter_ids] - soft_delete_ids, jobseeker_id: @jobseeker.id).destroy_all
    JobseekerCoverletter.where(id: params[:jobseeker_coverletter_ids], jobseeker_id: @jobseeker.id).destroy_all
    render json: @jobseeker.jobseeker_coverletters.try(:order, 'jobseeker_coverletters.default DESC')
  end

  private
    def set_jobseeker
      @jobseeker = User.find_by_id(params[:jobseeker_id]).try(:jobseeker)
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_jobseeker_coverletter
      @jobseeker_coverletter = JobseekerCoverletter.find_by_id(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def jobseeker_coverletter_params
      params.require(:jobseeker_coverletter).permit(:jobseeker_id, :title, :description, :default, :document, :is_deleted => false)
    end

    def jobseeker_owner
      if params[:jobseeker_id].nil? || @current_user.id != params[:jobseeker_id].to_i
        @current_ability.cannot params[:action].to_sym, JobseekerCoverletter
        authorize!(params[:action].to_sym, JobseekerCoverletter)
      end
    end
end
