class AddLogoImageToCareerFair < ActiveRecord::Migration
  def change
    add_attachment :career_fairs, :logo_image
  end
end
