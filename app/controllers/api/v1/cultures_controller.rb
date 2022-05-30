class Api::V1::CulturesController < ApplicationController
  skip_before_action :authenticate_user, only: [:index, :show]
  before_action :set_company
  before_action :set_culture, only: [:show, :update, :destroy]
  before_action :company_owner, only: [:create, :update, :destroy, :upload_avatar]

  # GET /cultures
  # GET /cultures.json
  def index
    @cultures = @company.cultures
    render json: @cultures
  end

  # GET /cultures/:id
  # GET /cultures/:id.json
  def show
    render json: @culture
  end

  # POST /cultures
  # POST /cultures.json
  def create
    @culture = @company.cultures.new(culture_params)

    if @culture.save
      render json: @culture
    else
      render json: @culture.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /cultures/1
  # PATCH/PUT /cultures/1.json
  def update
    if @culture.update(culture_params)
      render json: @culture
    else
      render json: @culture.errors, status: :unprocessable_entity
    end
  end

  # DELETE /cultures/1
  # DELETE /cultures/1.json
  def destroy
    @culture.destroy
    render json: @company.cultures
  end

  def upload_avatar
    if @culture.upload_avatar(params[:culture][:avatar])
      render json: @culture
    else
      render json: @culture.errors, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_culture
      @culture = Culture.find_by_id(params[:id])
    end

    def set_company
      @company = Company.active.find_by_id(params[:company_id])
      raise ActiveRecord::RecordNotFound if @company.nil?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def culture_params
      params.require(:culture).permit(:title, :avatar)
    end

    def company_owner
      if @current_user.is_employer? && (params[:company_id].nil? || !@current_user.company_ids.include?(params[:company_id].to_i))
        @current_ability.cannot params[:action].to_sym, Culture
        authorize!(params[:action].to_sym, Culture)
      end
    end
end
