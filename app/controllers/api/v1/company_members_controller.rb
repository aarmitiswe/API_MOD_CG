class Api::V1::CompanyMembersController < ApplicationController
  skip_before_action :authenticate_user, only: [:index, :show]
  before_action :set_company
  before_action :set_company_member, only: [:show, :update, :destroy, :upload_avatar, :delete_avatar]
  before_action :company_owner, only: [:create, :update, :destroy, :upload_avatar, :delete_avatar]

  # GET /company_members
  # GET /company_members.json
  def index
    @company_members = @company.company_members
    render json: @company_members
  end

  # GET /company_members/1
  # GET /company_members/1.json
  def show
    render json: @company_member
  end

  # POST /company_members
  # POST /company_members.json
  def create
    @company_member = @company.company_members.new(company_member_params)


    if @company_member.save
      render json: @company_member
    else
      render json: @company_member.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /company_members/1
  # PATCH/PUT /company_members/1.json
  def update
    if @company_member.update(company_member_params)
      render json: @company_member
    else
      render json: @company_member.errors, status: :unprocessable_entity
    end
  end

  # DELETE /company_members/1
  # DELETE /company_members/1.json
  def destroy
    @company_member.destroy
    render json: @company.company_members
  end

  def upload_avatar
    @company_member.upload_avatar(params[:company_member][:avatar])
    render json: @company_member
  end

  def delete_avatar
    @company_member.delete_avatar
    render json: @company_member
  end

  def delete_video
    @company_member.delete_video
    render json: @company_member
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_company_member
      @company_member = CompanyMember.find_by_id(params[:id])
    end

    def set_company
      @company = Company.find_by_id(params[:company_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def company_member_params
      params.require(:company_member).permit(:name, :position, :facebook_url, :twitter_url, :linkedin_url,
                                             :google_plus_url, :avatar, :video)
    end

    def company_owner
      if @current_user.is_employer? && (params[:company_id].nil? || !@current_user.company_ids.include?(params[:company_id].to_i))
        @current_ability.cannot params[:action].to_sym, CompanyMember
        authorize!(params[:action].to_sym, CompanyMember)
      end
    end
end
