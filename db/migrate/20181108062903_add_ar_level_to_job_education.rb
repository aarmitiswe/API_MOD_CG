class AddArLevelToJobEducation < ActiveRecord::Migration
  def change
    add_column :job_educations, :ar_level, :string
  end
end
