class CreateSuggestedCandidates < ActiveRecord::Migration
  def change
    create_table :suggested_candidates do |t|
      t.references :job, index: true, foreign_key: :job_id
      t.references :jobseeker, index: true, foreign_key: :jobseeker_id
      t.float :matching_percentage

      t.timestamps null: false
    end
  end
end
