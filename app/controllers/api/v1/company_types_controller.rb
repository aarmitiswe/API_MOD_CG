class Api::V1::CompanyTypesController < ApplicationController
  skip_before_action :authenticate_user
  before_action :set_company_type, only: [:show, :edit, :update, :destroy]

  # GET /company_types
  # GET /company_types.json
  def index
    @company_types = CompanyType.all
    render json: @company_types, each_serializer: CompanyTypeSerializer, ar: params[:ar]
  end

  # GET /company_types/1
  # GET /company_types/1.json
  def show
    render json: @company_type
  end

  private

    def set_company_type
      @company_type = CompanyType.find_by_id(params[:id])
    end
end
