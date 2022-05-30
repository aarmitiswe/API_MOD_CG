class JobseekerApplicationsSummarySerializer < ActiveModel::Serializer
  attributes :total, :successful, :unsuccessful, :in_progress


  def total
    self.object.job_applications.count
  end

  def successful
    self.object.job_applications.successful.count
  end

  def unsuccessful
    self.object.job_applications.unsuccessful.count
  end

  def in_progress
    self.object.job_applications.in_progress.count
  end


end
