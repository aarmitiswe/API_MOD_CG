class Api::V1::PackageBroadcastsController < ApplicationController
  before_action :set_package_broadcast, only: [:show, :edit, :update, :destroy]

  # GET /package_broadcasts
  # GET /package_broadcasts.json
  def index
    @package_broadcasts = PackageBroadcast.order(created_at: :asc)
    render json: @package_broadcasts
  end

  # GET /package_broadcasts/1
  # GET /package_broadcasts/1.json
  def show
    @num_remaining_credits = @current_user.jobseeker.num_remaining_credits
    render json: @package_broadcast, meta: {num_remaining_credits: @num_remaining_credits}
  end

  # GET /package_broadcasts/new
  def new
    @package_broadcast = PackageBroadcast.new
  end

  # GET /package_broadcasts/1/edit
  def edit
  end

  # POST /package_broadcasts
  # POST /package_broadcasts.json
  def create
    @package_broadcast = PackageBroadcast.new(package_broadcast_params)

    respond_to do |format|
      if @package_broadcast.save
        format.html { redirect_to @package_broadcast, notice: 'Package broadcast was successfully created.' }
        format.json { render :show, status: :created, location: @package_broadcast }
      else
        format.html { render :new }
        format.json { render json: @package_broadcast.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /package_broadcasts/1
  # PATCH/PUT /package_broadcasts/1.json
  def update
    respond_to do |format|
      if @package_broadcast.update(package_broadcast_params)
        format.html { redirect_to @package_broadcast, notice: 'Package broadcast was successfully updated.' }
        format.json { render :show, status: :ok, location: @package_broadcast }
      else
        format.html { render :edit }
        format.json { render json: @package_broadcast.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /package_broadcasts/1
  # DELETE /package_broadcasts/1.json
  def destroy
    @package_broadcast.destroy
    respond_to do |format|
      format.html { redirect_to package_broadcasts_url, notice: 'Package broadcast was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_package_broadcast
      @package_broadcast = PackageBroadcast.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def package_broadcast_params
      params.require(:package_broadcast).permit(:num_credits, :price, :currency, :description)
    end
end
