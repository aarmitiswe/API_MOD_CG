class Api::V1::JobseekerCertificatesController < ApplicationController
  before_action :set_jobseeker
  before_action :set_jobseeker_certificate, only: [:show, :update, :destroy, :delete_document, :upload_document]
  before_action :jobseeker_owner

  # GET /jobseeker_certificates
  # GET /jobseeker_certificates.json
  def index
    @jobseeker_certificates = @jobseeker.jobseeker_certificates
    render json: @jobseeker_certificates
  end

  # GET /jobseeker_certificates/1
  # GET /jobseeker_certificates/1.json
  def show
    render json: @jobseeker_certificate
  end


  # POST /jobseeker_certificates
  # POST /jobseeker_certificates.json
  def create
    @jobseeker_certificate = @jobseeker.jobseeker_certificates.new(jobseeker_certificate_params)

    if @jobseeker_certificate.save
      render json: @jobseeker_certificate
    else
      render json: @jobseeker_certificate.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /jobseeker_certificates/1
  # PATCH/PUT /jobseeker_certificates/1.json
  def update
    if @jobseeker_certificate.update(jobseeker_certificate_params)
      render json: @jobseeker_certificate
    else
      render json: @jobseeker_certificate.errors, status: :unprocessable_entity
    end
  end

  # DELETE /jobseeker_certificates/1
  # DELETE /jobseeker_certificates/1.json
  def destroy
    @jobseeker_certificate.destroy
    render json: @jobseeker.jobseeker_certificates
  end

  # POST /jobseeker_certificates/1/upload_document
  def upload_document
    @jobseeker_certificate.upload_document(params[:jobseeker_certificate][:document])
    render json: @jobseeker_certificate
  end

  # DELETE /jobseeker_certificates/1/delete_document
  def delete_document
    @jobseeker_certificate.delete_document
    render json: @jobseeker_certificate
  end

  private
    def set_jobseeker
      @jobseeker = User.find_by_id(params[:jobseeker_id]).try(:jobseeker)
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_jobseeker_certificate
      @jobseeker_certificate = JobseekerCertificate.find_by_id(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def jobseeker_certificate_params
      params.require(:jobseeker_certificate).permit(:from, :to, :jobseeker_id, :grade, :institute, :attachment, :name)
    end

    def jobseeker_owner
      if params[:jobseeker_id].nil? || @current_user.id != params[:jobseeker_id].to_i
        @current_ability.cannot params[:action].to_sym, JobseekerCertificate
        authorize!(params[:action].to_sym, JobseekerCertificate)
      end
    end
end
