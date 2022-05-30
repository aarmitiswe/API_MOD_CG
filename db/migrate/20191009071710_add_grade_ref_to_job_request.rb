class AddGradeRefToJobRequest < ActiveRecord::Migration
  def change
    add_reference :job_requests, :grade, index: true, foreign_key: true
  end
end
