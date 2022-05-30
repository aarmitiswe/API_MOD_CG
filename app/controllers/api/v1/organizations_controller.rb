class Api::V1::OrganizationsController < ApplicationController
  before_action :set_organization, only: [:show, :update, :destroy, :positions, :jobs, :children_organizations]

  # GET /organizations
  # GET /organizations.json
  def index
    # if params[:organization_type_id]
    #   @organizations = Organization.where(organization_type_id: params[:organization_type_id]).paginate(page: params[:page])
    # else
    #   @organizations = Organization.paginate(page: params[:page])
    # end

    per_page = params[:all] ? Organization.count : Organization.per_page
    @q = Organization.order(created_at: :desc).ransack(params[:q])
    @organizations = @q.result(distinct: true).paginate(page: params[:page], per_page: per_page)
    render json: @organizations, each_serializer: params[:mini]? OrganizationMiniSerializer : OrganizationSerializer, meta: pagination_meta(@organizations)
  end

  def current_user_organizations
    per_page = params[:all] ? Organization.count : Organization.per_page
    params[:q] ||= {}
    params[:q][:id_in] = @current_user.all_parent_children_organizations_ids if @current_user.is_hiring_manager?
    @q = Organization.order(created_at: :desc).ransack(params[:q])
    @organizations = @q.result.paginate(page: params[:page], per_page: per_page)
    render json: @organizations, each_serializer: params[:mini]? OrganizationMiniSerializer : OrganizationSerializer, meta: pagination_meta(@organizations)
  end

  # GET /organizations/1
  # GET /organizations/1.json
  def show
    render json: @organization
  end

  # POST /organizations
  # POST /organizations.json
  def create
    @organization = Organization.new(organization_params)

    if @organization.save
      render json: @organization
    else
      render json: @organization.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /organizations/1
  # PATCH/PUT /organizations/1.json
  def update
    if @organization.update(organization_params)
      render json: @organization
    else
      render json: @organization.errors, status: :unprocessable_entity
    end
  end

  # DELETE /organizations/1
  # DELETE /organizations/1.json
  def destroy
    # @organization.destroy
    if @organization.jobs.count > 0
      render json: { errors: [{jobs: "greated than zero"}] }
    elsif @organization.destroy
      render nothing: true, status: 204
    else
      render json: @organization.error
    end
    # render nothing: true, status: 204
  end

  # the user might belong to different organizations so we are passing an array here
  # TODO: Remove use this one
  def positions
    # @q = @organization.positions.ransack(params[:q])
    per_page = params[:all] ? Position.count : Position.per_page
    # @organizations = Organization.find(params[:id].split(','))
    # position_ids = []
    # @organizations.each do |org|
    #   position_ids << org.all_position_ids
    # end
    # position_ids = position_ids.flatten.uniq
    # @q = Position.where(id: @organization.all_position_ids).ransack(params[:q])
    position_ids = @organization.all_position_ids
    @q = Position.order(created_at: :desc).has_not_jobs.where(id: position_ids).ransack(params[:q])
    @positions = @q.result.paginate(page: params[:page], per_page: per_page)
    render json: @positions, each_serializer: PositionSerializer, meta: pagination_meta(@positions)
  end

  def jobs
    per_page = params[:all] ? Job.count : Job.per_page
    job_ids = @organization.all_job_ids
    @q = Job.order(created_at: :desc).where(id: job_ids).ransack(params[:q])
    @jobs = @q.result.paginate(page: params[:page], per_page: per_page)
    render json: @jobs, each_serializer: JobAuthorizedSerializer, meta: pagination_meta(@jobs)
  end

  def children_organizations
    per_page = params[:all] ? Organization.count : Organization.per_page
    @q = @organization.children_organizations.ransack(params[:q])
    @organizations = @q.result.paginate(page: params[:page], per_page: per_page)
    render json: @organizations, each_serializer: OrganizationSerializer, meta: pagination_meta(@organizations)
  end

  # /organizations/upload_organizations
  def upload_organizations
    Organization.import_xslx_file params[:organization][:file].tempfile.path
    render json: {uploaded: 'DONE'}
  end

  def push
    params[:organization][:organization_type_id] = OrganizationType.find_by_name(params[:organization][:organization_type][:name]).try(:id)
    params[:organization][:parent_organization_id] = Organization.find_by_oracle_id(params[:organization][:parent_oracle_organization_id]).try(:id)
    @organization = Organization.find_by_oracle_id(params[:organization][:oracle_id]) || Organization.new(organization_params)
    if (@organization.new_record? && @organization.save) || (!@organization.new_record? && @organization.update(organization_params))
      sleep 0.5
      render json: @organization
    else
      sleep 0.5
      render json: @organization.errors, status: :unprocessable_entity
    end
  end

  def remove
    @organization = Organization.find_by_oracle_id(params[:oracle_id])
    if @organization.nil?
      render json: {errors: {organization: 'Not Found'}}, status: :not_found
    elsif @organization.jobs.count > 0
      render json: { errors: [{jobs: "greated than zero"}] }
    elsif @organization.destroy
      render nothing: true, status: 204
    else
      render json: @organization.error
    end
    # @organization.destroy
    # render nothing: true, status: 204
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_organization
      # @organization = Organization.find(params[:id].split(','))
      @organization = Organization.find_by_id(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def organization_params
      params.require(:organization).permit(:name, :organization_type_id, :parent_organization_id, :oracle_id)
    end
end


# ["{\"organizations\":[{\"id\":1,\"name\":\"Ministry of Defence\",
#   \"organization_type_id\":1,\"organization_type\":{\"id\":1,\"name\":
#   \"Executive Office\",\"ar_name\":\"المكتب التنفيذي\",\"order\":1,
#   \"created_at\":\"2020-06-25T23:21:26.116Z\",\"updated_at\":
#   \"2020-06-25T23:21:26.116Z\"},\"parent_organization\":null,\"users\"
#   :[{\"id\":9,\"first_name\":\"recruitment\",\"last_name\":\"manager\"
#     ,\"gender\":null,\"country\":null,\"city\":null,\"state\":null,\"active\
#     ":true,\"email\":\"recruitementmanager-mod@mailinator.com\",\"document_e_signature
#     \":\"\",\"role_id\":4,\"role\":{\"id\":4,\"name\":\"Recruitment Manager\",
#     \"ar_name\":\"مدير التوظيف\",\"created_at\":\"2020-06-25T23:21:25.879Z\",\"
#     updated_at\":\"2020-06-25T23:21:25.879Z\"},\"organization_ids\":[1]}]}]}"]
