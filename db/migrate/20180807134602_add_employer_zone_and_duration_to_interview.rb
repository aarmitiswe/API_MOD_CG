class AddEmployerZoneAndDurationToInterview < ActiveRecord::Migration
  def change
    add_column :interviews, :employer_zone, :string
    add_column :interviews, :duration, :integer
  end
end
