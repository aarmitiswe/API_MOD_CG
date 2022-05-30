class Api::V1::MedicalInsurancesController < ApplicationController
  before_action :set_medical_insurance, only: [:show, :edit, :update, :destroy]

  # GET /medical_insurances
  # GET /medical_insurances.json
  def index
    @medical_insurances = MedicalInsurance.all
  end

  # GET /medical_insurances/1
  # GET /medical_insurances/1.json
  def show
  end

  # GET /medical_insurances/new
  def new
    @medical_insurance = MedicalInsurance.new
  end

  # GET /medical_insurances/1/edit
  def edit
  end

  # POST /medical_insurances
  # POST /medical_insurances.json
  def create
    @medical_insurance = MedicalInsurance.new(medical_insurance_params)
    if @medical_insurance.save
      render json: @medical_insurance
    else
      render json: @medical_insurance.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /medical_insurances/1
  # PATCH/PUT /medical_insurances/1.json
  def update
    if @medical_insurance.update(medical_insurance_params)
      render json: @medical_insurance
    else
      render json: @medical_insurance.errors, status: :unprocessable_entity
    end
  end

  # DELETE /medical_insurances/1
  # DELETE /medical_insurances/1.json
  def destroy
    @medical_insurance.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end


  def get_file_data
    @file = params[:medical_insurance][:document].tempfile

    render json: { medical_insurances: MedicalInsurance.get_medical_insurance(@file) }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_medical_insurance
      @medical_insurance = MedicalInsurance.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def medical_insurance_params
      params.require(:medical_insurance).permit(:jobseeker_id, :english_name, :arabic_name, :birthday, :id_number, :nationality_id, :start_date, :end_date, :relation)
    end
end
