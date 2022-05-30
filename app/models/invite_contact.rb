class InviteContact < ActiveRecord::Base

  def move_contacts_to_user_invitation user, provider
    user_inviatation = UserInvitation.find_or_create_by(user_id: user.id)
    user_inviatation.update_column("#{provider}_contacts".to_sym, self.contacts)
    self.destroy
  end
end
