class Api::V1::SavedJobSearchesController < ApplicationController
  before_action :set_jobseeker
  before_action :set_saved_job_search, only: [:update, :destroy]
  before_action :jobseeker_owner

  # GET /saved_job_searches
  # GET /saved_job_searches.json
  def index
    @saved_job_searches = @jobseeker.saved_job_searches.paginate(page: params[:page])
    render json: @saved_job_searches, meta: pagination_meta(@saved_job_searches)
  end

  # POST /saved_job_searches
  # POST /saved_job_searches.json
  def create
    @saved_job_search = @jobseeker.saved_job_searches.new(saved_job_search_params)

    if @saved_job_search.save
      render json: @saved_job_search
    else
      render json: @saved_job_search.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /saved_job_searches/1
  # PATCH/PUT /saved_job_searches/1.json
  def update
    if @saved_job_search.update(saved_job_search_params)
      render json: @saved_job_search
    else
      render json: @saved_job_search.errors, status: :unprocessable_entity
    end
  end

  # DELETE /saved_job_searches/1
  # DELETE /saved_job_searches/1.json
  def destroy
    @saved_job_search.destroy
    render json: @jobseeker.saved_job_searches
  end

  def delete_bulk
    SavedJobSearch.where(id: params[:saved_job_search_ids], jobseeker_id: @jobseeker.id).destroy_all
    render json: @jobseeker.saved_job_searches
  end

  private
    def set_jobseeker
      @jobseeker = User.find_by_id(params[:jobseeker_id]).try(:jobseeker)
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_saved_job_search
      @saved_job_search = SavedJobSearch.find_by_id(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def saved_job_search_params
      params.require(:saved_job_search).permit(:jobseeker_id, :title, :alert_type_id, :api_url, :web_url)
    end

    def jobseeker_owner
      if params[:jobseeker_id].nil? || @current_user.id != params[:jobseeker_id].to_i
        @current_ability.cannot params[:action].to_sym, SavedJobSearch
        authorize!(params[:action].to_sym, SavedJobSearch)
      end
    end
end
