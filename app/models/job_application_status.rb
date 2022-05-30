class JobApplicationStatus < ActiveRecord::Base
  SUCCESS = "Successful"
  UNSUCCESS = "Unsuccessful"

  KEYWORDS = {
      "Applied" => "Applied",
      "Reviewed" => "Reviewed",
      "Shortlisted" => "Shortlisted",
      "Selected" => "Selected",
      "Shared" => "Shared",
      "Interview" => "Interview",
      "PassInterview" => "PassInterview",
      "Assessment" => "Assessment",
      "SecurityClearance" => "SecurityClearance",
      "UnderOffer" => "UnderOffer",
      "AcceptOffer" => "AcceptOffer",
      "OnboardBeginner" => "OnboardBeginner",
      "OnboardJoining" => "OnboardJoining",
      "OnboardCompleted" => "OnboardCompleted",
      "Successful" => "Completed",
      "Unsuccessful" => "Unsuccessful",
      "Assessment" => "Assessment",
      "JobOffer" => "JobOffer",
      "OnBoarding" => "OnBoarding"
  }

  def self.update_recrods
    index = 1
    KEYWORDS.each do |key, val|
      JobApplicationStatus.find_or_create_by(status: val).update(order: index)
      index += 1
    end
  end

  def self.update_job_application_status
    job_app_status = JobApplicationStatus.find_by_status('Completed')
    if job_app_status.present?
      # Checking Completed Status is second last status
      if job_app_status.order == JobApplicationStatus.find_by_status('Unsuccessful').order - 1
        #Update only Arabic
      job_app_status.update(ar_status: 'مكتمل')
      else
        #Update only Arabic and Order
        job_app_status.update(ar_status: 'مكتمل', order: JobApplicationStatus.find_by_status('Unsuccessful').order)
        #Updating Unsuccessful Order
        JobApplicationStatus.change_unsuccessful_order
      end
    else
      #Creating Completed Status
      JobApplicationStatus.find_or_create_by(status: 'Completed', ar_status: 'مكتمل', order: JobApplicationStatus.find_by_status('Unsuccessful').order)
      #Updating Unsuccessful Order
      JobApplicationStatus.change_unsuccessful_order
    end
  end

  def self.change_unsuccessful_order
    JobApplicationStatus.find_by_status('Unsuccessful').update_column(:order, JobApplicationStatus.find_by_status('Unsuccessful').order + 1)
  end

end
