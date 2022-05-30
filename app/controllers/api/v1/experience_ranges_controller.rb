class Api::V1::ExperienceRangesController < ApplicationController
  skip_before_action :authenticate_user

  # GET /experience_ranges
  # GET /experience_ranges.json
  def index
    @experience_ranges = ExperienceRange.all
    render json: @experience_ranges
  end
end
