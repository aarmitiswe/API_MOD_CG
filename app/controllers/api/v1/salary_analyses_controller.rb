class Api::V1::SalaryAnalysesController < ApplicationController
  before_action :set_salary_analysis, only: [:show, :edit, :update, :destroy]

  # GET /salary_analyses
  # GET /salary_analyses.json
  def index
    @salary_analyses = SalaryAnalysis.all
  end

  # GET /salary_analyses/1
  # GET /salary_analyses/1.json
  def show
  end

  # POST /salary_analyses
  # POST /salary_analyses.json
  def create
    @salary_analysis = SalaryAnalysis.new(salary_analysis_params)
    if @salary_analysis.save
      render json: @salary_analysis
    else
      render json: @salary_analysis.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /salary_analyses/1
  # PATCH/PUT /salary_analyses/1.json
  def update
    if @salary_analysis.update(salary_analysis_params)
      render json: @salary_analysis
    else
      render json: @salary_analysis.errors, status: :unprocessable_entity
    end
  end

  # DELETE /salary_analyses/1
  # DELETE /salary_analyses/1.json
  def destroy
    @salary_analysis.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_salary_analysis
      @salary_analysis = SalaryAnalysis.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def salary_analysis_params
      params.require(:salary_analysis).permit(:job_application_id, :basic_salary, :housing_allowance, :transportation_allowance, :special_allowance, :ticket_allowance, :education_allowance, :incentives, :monthly_salary, :level)
    end
end
