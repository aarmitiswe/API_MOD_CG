class Api::V1::FeaturedCompaniesController < ApplicationController
  skip_before_action :authenticate_user

  # GET /featured_companies
  # GET /featured_companies.json
  def index
    @featured_companies = FeaturedCompany.all
    render json: @featured_companies
  end
end
