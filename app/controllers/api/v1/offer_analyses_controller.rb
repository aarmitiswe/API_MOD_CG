class Api::V1::OfferAnalysesController < ApplicationController
  before_action :set_offer_analysis, only: [:show, :edit, :update, :destroy]

  # GET /offer_analyses
  # GET /offer_analyses.json
  def index
    @offer_analyses = OfferAnalysis.all
  end

  # GET /offer_analyses/1
  # GET /offer_analyses/1.json
  def show
  end

  # POST /offer_analyses
  # POST /offer_analyses.json
  def create
    @offer_analysis = OfferAnalysis.new(offer_analysis_params)

    if @offer_analysis.save
      render json: @offer_analysis
    else
      render json: @offer_analysis.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /offer_analyses/1
  # PATCH/PUT /offer_analyses/1.json
  def update
    if @offer_analysis.update(offer_analysis_params)
      render json: @offer_analysis
    else
      render json: @offer_analysis.errors, status: :unprocessable_entity
    end
  end

  # DELETE /offer_analyses/1
  # DELETE /offer_analyses/1.json
  def destroy
    @offer_analysis.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_offer_analysis
      @offer_analysis = OfferAnalysis.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def offer_analysis_params
      params.require(:offer_analysis).permit(:job_application_id, :basic_salary, :housing_allowance, :transportation_allowance, :monthly_salary, :percentage_increase, :level)
    end
end
