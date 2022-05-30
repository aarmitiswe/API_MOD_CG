class Api::V1::ConfirmationsController < Devise::ConfirmationsController
  # def new
  #   super
  # end

  def create
    super
  end

  # This action to redirect to login page in Frontend after confirm account
  def show
    # super
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    yield resource if block_given?

    if resource && resource.is_jobseeker?
      resource.active = true
      resource.deleted = false
      resource.save(validate: false)
    end

    if resource
      # Send Notification to Admin
      redirect_to generate_url("#{Rails.application.secrets["FRONTEND"]}/login", confirmation: true)
    else
      redirect_to generate_url("#{Rails.application.secrets["FRONTEND"]}/login", confirmation: false)
    end
  end

  private
    def generate_url(url, params = {})
      uri = URI(url)
      uri.query = params.to_query
      uri.to_s
    end
end
