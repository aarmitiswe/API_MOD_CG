module Authenticable

  # Devise methods overwrites
  def current_user
    if !CompanySubscription.first.valid_activation_code
      return nil
    end
    @current_user ||= User.find_by(auth_token: request.headers['Authorization'])
    @current_user.update_last_active if @current_user.present?
    @current_user
  end

  def current_company
    if current_user.present? && !current_user.is_jobseeker?
      @current_company = Company.find_by_id(request.headers['company_id']) || @current_user.companies.first
      @current_employer = CompanyUser.find_by(user_id: @current_user.id, company_id: @current_company.id)
    end
  end

  # TODO: Remove this method. unused
  def authenticate_with_token!
    render json: { errors: [{message: 'Not authenticated'}] },
           status: :unauthorized unless current_user.present?
  end

  # This method that is using
  def authenticate_user
    if @current_user.nil?
      render json: { errors: [{message: 'This user is unauthenticated'}] },
             status: :unauthorized unless current_user.present?
    end
  end

  def user_signed_in?
    current_user.present?
  end

  def employer_signed_in?
    current_user.present? && !current_user.is_jobseeker?
  end

end
