
class Api::V1::PositionsController < ApplicationController
  before_action :set_position, only: [:show, :update, :destroy]
  #rescue_from ActiveRecord::InvalidForeignKey, with: :invalid_foreign_key

  # GET /positions
  # GET /positions.json
  def index
    params[:q] ||= {}
    # per_page = Position.per_page
    per_page = params[:all].blank? ? (params[:per_page] ||  Position.per_page) : Position.count
    if params[:q] && params[:q][:organization_id_in]
      organizations = Organization.where(id: params[:q][:organization_id_in])
      all_orgnaizations_ids = organizations.map{ |org| org.all_children_organizations.map(&:id) }.flatten
      params[:q][:organization_id_in] = all_orgnaizations_ids
    end
    @q = Position.active.has_not_jobs.order(created_at: :desc).ransack(params[:q])
    @positions = @q.result.paginate(page: params[:page], per_page: per_page)
    render json: @positions, each_serializer: (params[:mini])? PositionMiniSerializer : PositionSerializer , meta: pagination_meta(@positions)
  end

  # GET /positions/1
  # GET /positions/1.json
  def show
    render json: @position
  end

  # POST /positions
  # POST /positions.json
  def create
    @position = Position.create(position_params)

    if @position
      render json: @position
    else
      render json: @position.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /positions/1
  # PATCH/PUT /positions/1.json
  def update
    if @position.update(position_params)
      render json: @position
    else
      render json: @position.errors, status: :unprocessable_entity
    end
  end

  # DELETE /positions/1
  # DELETE /positions/1.json
  def destroy
    if @position.is_deleted
      render json: { errors: [{position: "is already deleted"}] }
    else
      @position.is_deleted= true;
      @position.save(validate: false)
      render json: { status: 200, position: @position }
    end
  end

  # def destroy
  #   if @position.jobs.count > 0
  #     render json: { errors: [{jobs: "greated than zero"}] }
  #   elsif @position.destroy
  #     render json: { status: 200, position: @position }
  #   else
  #     render json: @position.error
  #   end
  # end

  def push
    params[:position][:organization_id] = Organization.find_by_oracle_id(params[:position][:oracle_organization_id]).try(:id)
    if params[:position][:organization_id].nil?
      render json: {errors: {organization: 'Not Found'}}, status: :not_found
    else
      params[:position][:position_status_id] = PositionStatus.find_by_name(params[:position][:position_status][:name]).try(:id)
      params[:position][:grade_id] ||= Grade.find_by_name(params[:position][:grade]).try(:id) if params[:position][:grade].present?
      @position = Position.find_by_oracle_id(params[:position][:oracle_id]) || Position.new(position_params)
      if (@position.new_record? && @position.save) || (!@position.new_record? && @position.update(position_params))
        sleep 0.5
        render json: @position
      else
        sleep 0.5
        render json: @position.errors, status: :unprocessable_entity
      end
    end
  end

  def remove
    @position = Position.find_by_oracle_id(params[:oracle_id])
    if @position.nil?
      render json: {errors: {position: 'Not Found'}}, status: :not_found
    elsif @position.jobs.count > 0
      render json: { errors: [{jobs: "greated than zero"}] }
    elsif @position.destroy
      render nothing: true, status: 204
    else
      render json: @position.error
    end
  end

  # TODO: Ahmad comment it later
  def organization
    organization_ids = []

    params[:organization_id].split(',').each do |id|
      id = id.to_i
      organization = Organization.find_by_id(id)
      organization_ids << organization.id

      while organization.children_organizations.exists?
        organization = organization.children_organizations.first
        organization_ids << organization.id
      end
    end

    positions = Position.where(:organization_id => organization_ids.flatten.uniq)
    render json: positions

  end


  def invalid_foreign_key
    render json: {error: 'foreign_key'}, status: 403
  end


  private
  # Use callbacks to share common setup or constraints between actions.
  def set_position
    @position = Position.find_by_id(params[:id])
  end

  def position_params
    params.require(:position).permit(:job_title, :ar_job_title, :job_description, :employment_type, :military_level, :military_force,
                                     :job_status_id, :grade_id, :job_experience_level_id, :job_type_id, :organization_id, :position_cv_source_id, :oracle_id, :position_status_id)
  end
end