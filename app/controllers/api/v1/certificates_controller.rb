class Api::V1::CertificatesController < ApplicationController
  skip_before_action :authenticate_user
  before_action :set_certificate, only: [:show]

  # GET /certificates
  # GET /certificates.json
  def index
    @q = Certificate.order(:weight).ransack(params[:q])
    @certificates = @q.result.paginate(page: params[:page])
    render json: @certificates
  end

  # GET /certificates/1
  # GET /certificates/1.json
  def show
    render json: @certificate
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_certificate
      @certificate = Certificate.find_by_id(params[:id])
    end
end
