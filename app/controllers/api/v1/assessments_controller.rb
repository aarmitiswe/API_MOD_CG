class Api::V1::AssessmentsController < ApplicationController
  before_action :set_assessment, only: [:update]

  def update
    if @assessment.update(assessment_params)
      render json: @assessment
    else
      render json: @assessment.errors, status: :unprocessable_entity
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_assessment
    @assessment = Assessment.find_by_id(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def assessment_params
    params.require(:assessment).permit(:id, :assessment_type, :status, :comment, :document_report).merge!({user_id: @current_user.id})

  end

end
