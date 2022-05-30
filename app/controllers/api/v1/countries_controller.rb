class Api::V1::CountriesController < ApplicationController
  skip_before_action :authenticate_user
  before_action :set_country, only: [:cities,:show]

  # This is called if send wrong params to get cities & countries
  rescue_from NoMethodError, with: :render_exception_error

  # GET /api/v1/countries
  # GET /api/v1/countries?order=jobs
  def index
    per_page = params[:all] ? Country.count : Country.per_page
    params[:order] ||= "alphabetical"

    params[:q] ||= {}
    if !params[:all_nationality]
      params[:q][:name_cont] = "Saudi"
    end

    if params[:all] && params[:order] == "jobs"
      @q = Country.order_by_jobs_all.ransack(params[:q])
    end
    @q ||= Country.send("order_by_#{params[:order]}").ransack(params[:q])

    @countries = @q.result.paginate(page: params[:page], per_page: per_page)
    # @countries = @countries | Country.where.not(id: @countries.map(&:id)) if params[:all]
    render json: @countries, each_serializer: CountrySerializer, ar: params[:ar], meta: pagination_meta(@countries)
  end

  # GET /api/v1/  countries/1
  def show
    render json: @country
  end

  # GET /api/countries/1/cities
  # GET /api/countries/1/cities?order=jobs
  def cities
    params[:q] ||= {}
    params[:q][:country_id_eq] ||= @country.id
    params[:order] ||= "alphabetical"

    per_page = params[:all] ? City.count : City.per_page

    # TODO: Refactor it when clear DB
    @q = City.send("order_by_#{params[:order]}").ransack(params[:q])
    @cities = @q.result.paginate(page: params[:page], per_page: per_page)
    render json: @cities, root: :cities, order: params[:order]
  end

  def country_pdf
    render pdf: 'test_pdf', handlers: [:erb], formats: [:html]
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_country
      @country = Country.find_by_id(params[:id])
    end

    def render_exception_error
      render json: {message: "Wrong Params"}, status: :bad_request
    end
end
