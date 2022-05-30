class ChangeCopyNumberFromNumberToString < ActiveRecord::Migration
  def change
    change_column :boarding_forms, :copy_number, :string
  end
end
