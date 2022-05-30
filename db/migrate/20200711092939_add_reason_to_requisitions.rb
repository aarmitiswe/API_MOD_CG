class AddReasonToRequisitions < ActiveRecord::Migration
  def change
    add_column :requisitions, :reason, :text
  end
end
