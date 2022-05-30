class Api::V1::CompanySizesController < ApplicationController
  skip_before_action :authenticate_user
  before_action :set_company_size, only: [:show]

  # GET /company_sizes
  # GET /company_sizes.json
  def index
    @company_sizes = CompanySize.active.order(:display_order)
    render json: @company_sizes
  end

  # GET /company_sizes/1
  # GET /company_sizes/1.json
  def show
    render json: @company_size
  end

  private
    def set_company_size
      @company_size = CompanySize.find_by_id(params[:id])
    end
end
