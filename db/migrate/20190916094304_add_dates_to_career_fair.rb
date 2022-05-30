class AddDatesToCareerFair < ActiveRecord::Migration
  def change
    add_column :career_fairs, :from, :date
    add_column :career_fairs, :to, :date
  end
end
