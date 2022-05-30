class JobEducation < ActiveRecord::Base
  def name
    self.level
  end

  def ar_name
    self.ar_level
  end
end
