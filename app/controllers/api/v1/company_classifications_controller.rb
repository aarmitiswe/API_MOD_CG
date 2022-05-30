class Api::V1::CompanyClassificationsController < ApplicationController
  skip_before_action :authenticate_user
  before_action :set_company_classification, only: [:show, :update, :destroy]

  # GET /company_classifications
  # GET /company_classifications.json
  def index
    @company_classifications = CompanyClassification.all
    render json: @company_classifications, each_serializer: CompanyClassificationSerializer, ar: params[:ar]
  end

  # GET /company_classifications/1
  # GET /company_classifications/1.json
  def show
    render json: @company_classification
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_company_classification
      @company_classification = CompanyClassification.find_by_id(params[:id])
    end
end
