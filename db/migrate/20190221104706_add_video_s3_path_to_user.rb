class AddVideoS3PathToUser < ActiveRecord::Migration
  def change
    add_column :users, :video_s3_path, :string
  end
end
