class CreatePositionCvSources < ActiveRecord::Migration
  def change
    create_table :position_cv_sources do |t|
      t.string :name
      t.string :ar_name
    end
  end
end
