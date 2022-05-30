class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  respond_to :json

  # rescue from ActiveRecord Record Not found exceptions
  rescue_from ActiveRecord::RecordNotFound, with: :render_exception_error

  # Call unauthenticated concern to check authonocation of user
  include Authenticable
  # Call cancancan authorization to check role of current user
  include CanCan::ControllerAdditions

  # Skipping acions
  # skip_before_action :create

  # Before Actions
  # Creating current_user as helper method because conflicts between cancancan & Devise
  # https://github.com/ryanb/cancan/issues/138  && https://github.com/ryanb/cancan/issues/164
  helper_method :current_user
  before_action :authenticate_user, :current_user, unless: :devise_controller?
  before_action :current_company, unless: :devise_controller?

  # Pass current_user to serializer
  serialization_scope :view_context
  # Call authorize before each action
  # Skip check authorization for devise controller
  load_and_authorize_resource :unless => :devise_controller?
  before_filter :set_headers

  def set_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
  end

  # This method to add pagination options
  def pagination_meta(object)
    {
        current_page: object.current_page,
        next_page: object.next_page,
        prev_page: object.previous_page,
        total_pages: object.total_pages,
        total_count: object.total_entries
    }
  end

  # Handle json of unauthorized user
=begin
  rescue_from CanCan::AccessDenied do |exception|
    render json: { errors: [{message: "This user unauthorize for this request"}] }, status: :forbidden
    ## to avoid deprecation warnings with Rails 3.2.x (and incidentally using Ruby 1.9.3 hash syntax)
    ## this render call should be:
    # render file: "#{Rails.root}/public/403", formats: [:html], status: 403, layout: false
  end
=end

  # Handle json of unauthenticated user
  protected
  def ensure_params_exist
    return unless request.headers['Authorization'].blank?
    render json: { errors: [{message: "Missing authentication token"}] }, status: 403
  end

  # Render exceptions errors
  def render_exception_error(error)
    render json: {message: error.message}, status: :not_found
  end

end
