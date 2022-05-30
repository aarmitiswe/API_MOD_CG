class Api::V1::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  [:twitter_login, :facebook, :linked_in, :linkedin, :google_oauth2].each do |provider|
    define_method(provider) do
      @current_user ||= User.find_for_oauth(env["omniauth.auth"])
      if @current_user && @current_user.respond_to?(:persisted?) && @current_user.persisted?
        @current_user.update_tracked_fields!(warden.request)
        redirect_to generate_url(Rails.application.secrets["FRONTEND"], auth_token: @current_user.auth_token, id: @current_user.id, provider: provider, role: @current_user.role)
      else
        if @current_user.nil?
          redirect_to generate_url("#{Rails.application.secrets['FRONTEND']}/login")
        else
          redirect_to generate_url("#{Rails.application.secrets['FRONTEND']}/signup_jobseeker", first_name: @current_user[:first_name], last_name: @current_user[:last_name], provider: provider, error: true)
        end
      end
    end
  end

  def generate_url(url, params = {})
    uri = URI(url)
    uri.query = params.to_query
    uri.to_s
  end

  # Override original one, to redirect to Frontend Web
  def failure
    redirect_to generate_url(Rails.application.secrets['FRONTEND'])
  end
end