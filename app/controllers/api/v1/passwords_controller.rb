class Api::V1::PasswordsController < Devise::PasswordsController
  respond_to :json, :html

  # This controller for reset password without Auth-token
  def new
    super
  end

  # This method to send reset password by forget password
  # {user: {email: ""}}
  def create
    super
  end

  # TODO: Using super not working ??
  def update
    super
    # user = User.find_by(email: params[:user][:email])
    # if user
    #   if user.reset_password_token == params[:user][:reset_password_token]
    #     user.skip_validation_birth = true
    #     if user.reset_password!(params[:user][:password], params[:user][:password_confirmation]) && user.generate_authentication_token! && user.save!
    #         render json: user
    #     else
    #       render json: user.errors, status: :unprocessable_entity
    #     end
    #   else
    #     render json: {user: {error: "'Reset Password' link already used. Use 'Forgot Password' to reactivate."}}, status: :unprocessable_entity
    #   end
    # else
    #   render json: {user: {error: "Email is not exist"}}, status: :unprocessable_entity
    # end
  end

  def edit
    super
    render json: {reset_password_token: resource.reset_password_token}
  end
end
