class Api::V1::OrganizationTypesController < ApplicationController

  def index
    @organization_types = OrganizationType.where.not(name: 'Executive Office').order(id: :asc)
    render json: @organization_types, each_serializer: OrganizationTypeSerializer, ar: params[:ar]
  end

end
