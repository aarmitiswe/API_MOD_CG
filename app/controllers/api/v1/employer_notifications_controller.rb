class Api::V1::EmployerNotificationsController < ApplicationController
  before_action :set_employer_notification, only: [:show, :update, :destroy]

  # GET /employer_notifications
  # GET /employer_notifications.json
  def index
    @q = @current_user.employer_notifications.order(created_at: :desc).ransack(params[:q])
    @employer_notifications = @q.result.paginate(page: params[:page])
    render json: @employer_notifications, meta: pagination_meta(@employer_notifications),
           each_serializer: EmployerNotificationSerializer, ar: params[:ar]
  end

  # GET /employer_notifications/1
  # GET /employer_notifications/1.json
  def show
    render json: @employer_notification
  end

  # POST /employer_notifications
  # POST /employer_notifications.json
  def create
    @employer_notification = EmployerNotification.new(employer_notification_params)

    if @employer_notification.save
      render json: @employer_notification
    else
      render json: @employer_notification.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /employer_notifications/1
  # PATCH/PUT /employer_notifications/1.json
  def update
    if @employer_notification.update(employer_notification_params)
      render json: @employer_notification
    else
      render json: @employer_notification.errors, status: :unprocessable_entity
    end
  end

  # DELETE /employer_notifications/1
  # DELETE /employer_notifications/1.json
  def destroy
    @employer_notification.destroy
    render nothing: true, status: 204
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_employer_notification
      @employer_notification = @current_user.employer_notifications.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def employer_notification_params
      params.require(:employer_notification).permit(:notifiable_id, :notifiable_type, :user_id, :finished_action,
                                                    :needed_action, :email_template_id, :subject, :content, :status,
                                                    :page_url)
    end
end
