class JobseekerUserSerializer < GenericUserSerializer
  attributes :id, :email, :first_name, :last_name, :birthday, :country, :city, :state, :profile_image, :gender
end
