class Api::V1::SessionsController < Devise::SessionsController
  # Tell warden that params authentication is allowed for that specific page
  prepend_before_filter :allow_params_authentication!, only: :create

  # Login Method
  def create
    User.where(confirmed_at: nil).each{|u| u.update_column(:confirmed_at, DateTime.now)}
    self.resource = warden.authenticate!(auth_options)
    self.resource.set_auth_token if self.resource.present?
    if self.resource && !self.resource.active && self.resource.is_employer?
      render json: {errors: ['deactivated']}, status: :forbidden
    else
      sign_in(resource_name, resource)
      # TODO: Remove Comment
      # resource.generate_authentication_token!
      # This line to re-active jobseeker
      # resource.change_status('activate') unless resource.active
      # TODO: Remove this one in ATS project
      # if resource.is_jobseeker? && resource.created_at <  DateTime.new(2017,8,1,0,0,0,'+0') && resource.jobseeker.complete_step.nil?
      #   resource.jobseeker.complete_step = resource.jobseeker.current_step
      # end
      resource.save(validate: false)

      company_subscription = resource.company.company_subscription
      can_login = company_subscription.present? && company_subscription.valid_activation_code
      expires_at = company_subscription.expires_at

      if can_login
        render json: {
            auth_token: resource.auth_token,
            can_login: true,
            expires_at: expires_at,
            expire: true,
            permissions: resource.permissions_names,
            role: resource.role,
            company_id: resource.company.try(:id),
            employer_id: resource.employer.try(:id),
            user_id: resource.id,
            company_user_id: resource.company_users.first.try(:id),
            all_organization_ids: resource.all_organization_ids,
            user: resource,
            organization_ids: resource.organizations.pluck(:id),
            organizations: resource.organizations.map{|org| {id: org.id, name: org.try(:name), organization_type: {id: org.organization_type_id, name: org.organization_type.try(:name)}}},
            top_organization: {organization: resource.top_organization, order: resource.try(:top_organization).try(:organization_type).try(:order)},
            is_approver: resource.is_approver,
            is_last_approver: resource.is_last_approver
        }
      else
        render json: {
          auth_token: nil,
          can_login: false,
          expires_at: expires_at,
        }
      end


    end
  end

  def destroy
    current_user.generate_authentication_token!
    current_user.save
    head 204
  end

  def verify_signed_out_user
    authenticate_with_token!
  end

  # Warden::Manager.before_failure do |env, opts|
  #   email = env["action_dispatch.request.request_parameters"][:user] &&
  #       env["action_dispatch.request.request_parameters"][:user][:email]
  #   # unfortunately, the User object has been lost by the time
  #   # we get here; so we take a db hit because I care to see
  #   # if the email matched a user account in our system
  #   user_exists = User.where(email: email).exists?
  #
  #   if opts[:message] == :unconfirmed
  #     # this is a special case for me because I'm using :confirmable
  #     # the login was correct, but the user hasn't confirmed their
  #     # email address yet
  #     ::Rails.logger.info "*** Login Failure: unconfirmed account access: #{email}"
  #   elsif opts[:action] == "unauthenticated"
  #     # "unauthenticated" indicates a login failure
  #     if !user_exists
  #       # bad email:
  #       # no user found by this email address
  #       ::Rails.logger.info "*** Login Failure: bad email address given: #{email}"
  #     else
  #       # the user exists in the db, must have been a bad password
  #       ::Rails.logger.info "*** Login Failure: email-password mismatch: #{email}"
  #     end
  #   end
  # end
end
