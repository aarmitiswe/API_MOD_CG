class CustomAuthFailure < Devise::FailureApp
  def respond
    self.status        = 401
    self.content_type  = 'json'
    if warden_message == :unconfirmed
      self.response_body = { errors: ['unconfirmed'] }.to_json
    elsif warden_message == :not_found_in_database
      self.response_body = { errors: ['invalid_email'] }.to_json
    else
      self.response_body = { errors: ['invalid_password'] }.to_json
    end
  end
end