class Api::V1::UserInvitationsController < ApplicationController
  skip_before_action :authenticate_user, only: [:invite, :failure, :get_twitter_friends]
  
  def invite
    @contacts = format_response request.env['omnicontacts.contacts'], params[:provider]
    invite_contact = InviteContact.create(contacts: @contacts[:user_invitations])
    redirect_to generate_url("#{Rails.application.secrets["FRONTEND"]}/core/invite-connections",
                             invite_contact_id: invite_contact.id, provider: params[:provider])
  end

  def get_contacts
    invite_contact = InviteContact.find_by_id(params[:invite_contact_id])
    @contacts = invite_contact.try(:contacts) || @current_user.user_invitation.send("#{params[:provider]}_contacts")
    @contacts.map!{|contact| eval(contact)}
    invite_contact.delay.move_contacts_to_user_invitation @current_user, params[:provider] unless invite_contact.nil?
    render json: @contacts
  end

  def failure
    redirect_to generate_url("#{Rails.application.secrets["FRONTEND"]}/core/invite-connections")
  end

  def get_twitter_friends
    twitter_auth = request.env['omniauth.auth']

    user_twitter_auth = {
        access_token: twitter_auth['extra']['access_token'].params[:oauth_token],
        access_token_secret: twitter_auth['extra']['access_token'].params[:oauth_token_secret],
        twitter_name: twitter_auth['info']['nickname']
    }

    @contacts = UserInvitation.fetch_twitter_freinds(user_twitter_auth)

    invite_contact = InviteContact.create(contacts: @contacts)

    redirect_to generate_url("#{Rails.application.secrets["FRONTEND"]}/core/invite-connections",
                             invite_contact_id: invite_contact.id, provider: "twitter",
                             twitter_key: user_twitter_auth[:access_token],
                             twitter_secret: user_twitter_auth[:access_token_secret])
  end

  # POST /users/:user_id/invite_by_email
  # params = {send_invitations: {template_type: "invite_jobseeker", receivers: [{email: "", name: ""}],
  # message_body: "", receiver_ids}}
  def invite_by_email
    params[:user_invitation][:receivers] ||= User.where(id: params[:user_invitation][:receiver_ids]).map{|u| {name: u.full_name, email: u.email}}
    @current_user.delay.send_email(params[:user_invitation][:template_type],
                           params[:user_invitation][:receivers],
                           {message_body: params[:user_invitation][:message_body],
                            message_subject: "Invitation to Join BLOOVO.COM - An Innovative Online Recruitment Platform"})
    render json: {message: 'Success', status: :ok}
  end


  def invite_by_twitter
    user_twitter_auth = {
        access_token: params[:user_invitation][:twitter_key],
        access_token_secret: params[:user_invitation][:twitter_secret]
    }

    @current_user.delay.send_msg_twitter(user_twitter_auth, params[:user_invitation][:template_type],
                                 params[:user_invitation][:receivers],
                                 {message_body: params[:user_invitation][:message_body],
                                  message_subject: "Invitation to Join BLOOVO.COM - An Innovative Online Recruitment Platform"})
    render json: {message: 'Success', status: :ok}
  end

  def format_response contacts, provider
    user_invitations = []

    contacts.each do |contact|
      user_invitations.push({name: contact[:name],
                             email: contact[:email],
                             profile_picture: contact[:profile_picture]
                            })
    end
    {user_invitations: user_invitations}
  end

  def generate_url(url, params = {})
    uri = URI(url)
    uri.query = params.to_query
    uri.to_s
  end
end
