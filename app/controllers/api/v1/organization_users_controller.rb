class Api::V1::OrganizationUsersController < ApplicationController
  before_action :set_organization_user, only: [:show, :edit, :update, :destroy]

  # GET /organization_users
  # GET /organization_users.json
  def index
    @organization_users = OrganizationUser.all
    render json: @organization_users
  end

  # GET /organization_users/1
  # GET /organization_users/1.json
  def show
    render json: @organization_user
  end

  # POST /organization_users
  # POST /organization_users.json
  def create
    @organization_user = OrganizationUser.new(organization_user_params)

    if @organization_user.save
      render json: @organization_user
    else
      render json: @organization_user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /organization_users/1
  # PATCH/PUT /organization_users/1.json
  def update
    if @organization_user.update(organization_user_params)
      render json: @organization_user
    else
      render json: @organization_user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /organization_users/1
  # DELETE /organization_users/1.json
  def destroy
    @organization_user.destroy
    render nothing: true, status: 204
  end

  def push
    params[:organization_user][:organization_id] = Organization.find_by_oracle_id(params[:organization_user][:oracle_organization_id]).try(:id)
    params[:organization_user][:user_id] = User.find_by_oracle_id(params[:organization_user][:oracle_user_id]).try(:id)
    @organization_user = OrganizationUser.new(organization_user_params)
    if params[:organization_user][:organization_id].nil?
      sleep 0.5
      render json: {errors: {organization: 'Not Found'}}, status: :not_found
    elsif params[:organization_user][:user_id].nil?
      sleep 0.5
      render json: {errors: {user: 'Not Found'}}, status: :not_found
    elsif @organization_user.save
      sleep 0.5
      render json: @organization_user
    else
      sleep 0.5
      render json: @organization_user.errors, status: :unprocessable_entity
    end
  end

  def remove
    organization = Organization.find_by_oracle_id(params[:organization_user][:oracle_organization_id])
    user = User.find_by_oracle_id(params[:organization_user][:oracle_user_id])

    if organization.present? && user.present?
      @organization_user = OrganizationUser.find_by(user_id: user.id, organization_id: organization.id)
      if @organization_user.present?
        @organization_user.destroy
        render nothing: true, status: 204
      else
        render json: {errors: [{organization_user: "not found"}]}, status: :not_found
      end
    else
      render json: {errors: [{user: "not found"}, {organization: "not found"}]}, status: :not_found
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_organization_user
      @organization_user = OrganizationUser.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def organization_user_params
      params.require(:organization_user).permit(:organization_id, :user_id, :is_manager)
    end
end
