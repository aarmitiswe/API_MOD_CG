class RemoveCareerFairLogoImage < ActiveRecord::Migration
  def change
    remove_column :career_fairs, :logo_image, :string
  end
end
