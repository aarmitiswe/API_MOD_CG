class Api::V1::SalaryRangesController < ApplicationController
  skip_before_action :authenticate_user

  # GET /salary_ranges
  # GET /salary_ranges.json
  def index
    @q = SalaryRange.order(:salary_from).ransack(params[:q])
    @salary_ranges = @q.result
    render json: @salary_ranges
  end
end
