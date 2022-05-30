class AddAvatarS3PathToUser < ActiveRecord::Migration
  def change
    add_column :users, :avatar_s3_path, :string
  end
end
