class AddCommentToBoardingRequisition < ActiveRecord::Migration
  def change
    add_column :boarding_requisitions, :comment, :text
  end
end
