class Api::V1::PackagesController < ApplicationController

  def index
    @packages = Package.order(:price)
    render json: @packages, each_serializer: PackageSerializer, root: :packages, ar: params[:ar]
  end

  def show
    @package = Package.find_by_id(params[:id])
    render json: @package, serializer: PackageSerializer, root: :package, ar: params[:ar]
  end
end