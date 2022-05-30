class Api::V1::SkillsController < ApplicationController
  skip_before_action :authenticate_user
  # GET /skills
  # GET /skills.json
  def index
    @q = Skill.where(is_auto_complete: true).order(weight: :desc).ransack(params[:q])
    @skills = @q.result.paginate(page: params[:page])
    render json: @skills
  end
end
