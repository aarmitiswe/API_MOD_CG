class Api::V1::JobseekerPackageBroadcastsController < ApplicationController
  before_action :set_jobseeker_package_broadcast, only: [:show, :edit, :update, :destroy]

  # GET /jobseeker_package_broadcasts
  # GET /jobseeker_package_broadcasts.json
  def index
    @jobseeker_package_broadcasts = @current_user.jobseeker.jobseeker_package_broadcasts
    @num_remaining_credits = @current_user.jobseeker.num_remaining_credits

    render json: @jobseeker_package_broadcasts, each_serializer: JobseekerPackageBroadcastSerializer,
           root: :jobseeker_package_broadcasts,
           meta: {
               num_remaining_credits: @num_remaining_credits,
               total_num_credits: @current_user.jobseeker.package_broadcasts.sum(:num_credits)
           }
  end

  # GET /jobseeker_package_broadcasts/1
  # GET /jobseeker_package_broadcasts/1.json
  def show
  end

  # GET /jobseeker_package_broadcasts/new
  def new
    @jobseeker_package_broadcast = JobseekerPackageBroadcast.new
  end

  # GET /jobseeker_package_broadcasts/1/edit
  def edit
  end

  # POST /jobseeker_package_broadcasts
  # POST /jobseeker_package_broadcasts.json
  def create
    @jobseeker_package_broadcast = JobseekerPackageBroadcast.new(jobseeker_package_broadcast_params)

    respond_to do |format|
      if @jobseeker_package_broadcast.save
        format.html { redirect_to @jobseeker_package_broadcast, notice: 'Jobseeker package broadcast was successfully created.' }
        format.json { render :show, status: :created, location: @jobseeker_package_broadcast }
      else
        format.html { render :new }
        format.json { render json: @jobseeker_package_broadcast.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /jobseeker_package_broadcasts/1
  # PATCH/PUT /jobseeker_package_broadcasts/1.json
  def update
    respond_to do |format|
      if @jobseeker_package_broadcast.update(jobseeker_package_broadcast_params)
        format.html { redirect_to @jobseeker_package_broadcast, notice: 'Jobseeker package broadcast was successfully updated.' }
        format.json { render :show, status: :ok, location: @jobseeker_package_broadcast }
      else
        format.html { render :edit }
        format.json { render json: @jobseeker_package_broadcast.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /jobseeker_package_broadcasts/1
  # DELETE /jobseeker_package_broadcasts/1.json
  def destroy
    @jobseeker_package_broadcast.destroy
    respond_to do |format|
      format.html { redirect_to jobseeker_package_broadcasts_url, notice: 'Jobseeker package broadcast was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_jobseeker_package_broadcast
      @jobseeker_package_broadcast = JobseekerPackageBroadcast.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def jobseeker_package_broadcast_params
      params.require(:jobseeker_package_broadcast).permit(:jobseeker_id, :package_broadcast_id)
    end
end
