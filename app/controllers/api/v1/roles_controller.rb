class Api::V1::RolesController < ApplicationController
  skip_before_action :authenticate_user

  def index
    @roles = Role.where.not(name: 'Super Admin')
    render json: @roles
  end
end


