class AddArLevelToJobExperienceLevel < ActiveRecord::Migration
  def change
    add_column :job_experience_levels, :ar_level, :string
  end
end
