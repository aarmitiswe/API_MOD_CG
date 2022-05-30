class Api::V1::UsersController < ApplicationController
  skip_before_action :authenticate_user, only: [:generate_new_password_email, :valid_email, :refresh_mails]

  # before_action :authenticate_with_token!, only: [:update, :destroy]
  before_action :user_owner, only: [:update_notification, :upload_profile_image,
                                    :upload_video, :delete_video, :activate, :deactivate,:delete_avatar]

  def logged_in
    render json: {user: @current_user, top_organization: {organization: @current_user.top_organization, order: @current_user.top_organization.try(:organization_type).try(:order)}}
  end

  def refresh_mails
    User.new_refresh_mails
    render json: {message: "OK"}
  end

  def create
    user = User.new(user_params)
    if user.save
      render json: user, status: 201, location: [:api, user]
    else
      render json: { errors: user.errors }, status: 422
    end
  end

  # This action is use to update email & password
  # PUT /users/:user_id
  def update
    user = current_user

    if user.update_with_password(user_params)
      render json: user
    else
      render json: user.errors, status: :unprocessable_entity
    end
  end

  # PUT /users/:user_id/activate
  def activate
    if @user.change_status 'activate'
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PUT /users/:user_id/deactivate
  def deactivate
    if @user.change_status 'deactivate'
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def shared_jobseekers

  end

  def received_jobseekers

  end

  def positions
    # @q = @organization.positions.ransack(params[:q])
    @q = Position.where(id: @current_user.all_position_ids).ransack(params[:q])
    @positions = @q.result.paginate(page: params[:page])
    render json: @positions, each_serializer: PositionSerializer, meta: pagination_meta(@positions)
  end

  # GET /users/:user_id/get_notification
  def get_notification
    @notification = @user.notification
    # This code to handle blank notification
    @notification = Notification.create(user_id: @user.id, blog: 0, job: 0, candidate: 0, poll_question: 0) if @notification.nil?
    render json: @notification
  end

  # PUT /users/:user_id/update_notification
  def update_notification
    @notification = @user.notification
    # This to update visible by employer flag
    @jobseeker = @user.jobseeker
    if !params[:notification][:visible_by_employer].nil? && !@jobseeker.nil?
      @jobseeker.update_column(:visible_by_employer, params[:notification][:visible_by_employer])
    end

    if @notification.update(notification_params)
      render json: @notification
    else
      render json: @notification.errors, status: :unprocessable_entity
    end
  end

  def destroy
    user = User.find_by_id(params[:id])
    user.destroy
    head 204
  end

  def upload_profile_image
    if @user.upload_profile_image(params[:users][:profile_image])
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def upload_video
    if @user.upload_video(params[:users][:video], "video")
      @user.send_video_notification
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def delete_video
    @user.video = nil
    if @user.save
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def delete_avatar
    @user.avatar = nil
    if @user.save
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # TODO: This action forget password, Change: Use our template
  def generate_new_password_email
    @user = User.find_by_email(params[:user][:email].try(:downcase))
    if @user.present?
      @user.send_reset_password_instructions
      if @user.confirmed_at.blank?
        @user.confirmed_at = DateTime.now
        @user.save
      end
      render json: {user: {send: "Success"}}
    else
      render json: {user: {error: "User not found."}}, status: :unprocessable_entity
    end
  end

  def valid_email
    render json: {user: {valid: User.find_by_email(params[:user][:email]).nil?}}
  end

  private

    def user_params
      params.require(:user).permit(:email, :current_password, :password, :password_confirmation)
    end

    def notification_params
      params.require(:notification).permit(:blog, :job, :poll_question, :newsletter, :candidate)
    end

    def set_user
      @user = User.find_by_id(params[:id])
    end

    def user_owner
      set_user

      if @current_user.id != @user.id
        @current_ability.cannot params[:action].to_sym, User
        authorize!(params[:action].to_sym, User)
      end
    end
end
