class Api::V1::EventVisitorsController < ApplicationController
  respond_to :json
  skip_before_action :authenticate_user
  skip_authorize_resource

  # GET /api/v1/event_visitors
  # GET /api/v1/event_visitors.json
  def index
    @event_visitors = EventVisitor.all
  end

  # GET /api/v1/event_visitors/1
  # GET /api/v1/event_visitors/1.json
  def show
  end

  # GET /api/v1/event_visitors/new
  def new
    @event_visitor = EventVisitor.new
  end

  # GET /api/v1/event_visitors/1/edit
  def edit
  end

  # POST /api/v1/event_visitors
  # POST /api/v1/event_visitors.json
  def create
    @event_visitor = EventVisitor.new(event_visitor_params)

    respond_to do |format|
      if @event_visitor.save
        @bloovo_mailer = BloovoMailer.new
        @bloovo_mailer.send_event_email(event_visitor_params)
        format.html { redirect_to @event_visitor, notice: 'Event visitor was successfully created.' }
        format.json { render :show, status: :created}
      else
        format.html { render :new }
        format.json { render json: @event_visitor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /api/v1/event_visitors/1
  # PATCH/PUT /api/v1/event_visitors/1.json
  def update
    respond_to do |format|
      if @event_visitor.update(event_visitor_params)
        format.html { redirect_to @event_visitor, notice: 'Event visitor was successfully updated.' }
        format.json { render :show, status: :ok, location: @event_visitor }
      else
        format.html { render :edit }
        format.json { render json: @event_visitor.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /api/v1/event_visitors/1
  # DELETE /api/v1/event_visitors/1.json
  def destroy
    @event_visitor.destroy
    respond_to do |format|
      format.html { redirect_to event_visitors_url, notice: 'Event visitor was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event_visitor
      @event_visitor = EventVisitor.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_visitor_params
      params.require(:event_visitor).permit(:name, :company, :position, :department, :mobile_phone, :email)
    end
end
