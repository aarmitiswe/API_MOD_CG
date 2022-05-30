class UserSerializer < GenericUserSerializer
  attributes :id, :first_name, :last_name, :gender, :country,  :city, :state, :active, :email, :document_e_signature,
             :role_id, :role, :organization_ids, :offer_approver_position, :is_last_approver

  def organization_ids
    object.organizations.pluck(:id)
  end

  def offer_approver_position
    object.offer_approver.try(:position)
  end

end
