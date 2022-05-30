class UserInvitation < ActiveRecord::Base
  include SendInvitation
  belongs_to :user

  def self.fetch_twitter_freinds twitter_auth
    client = self.get_twitter_client twitter_auth

    friends = client.friends(twitter_auth[:twitter_name])
    twitter_friends = []
    friends.each do |friend|
      twitter_friends.push({screen_name: friend.screen_name, profile_image_url: friend.profile_image_url.to_s})
    end
    twitter_friends
  end
end
