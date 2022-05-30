class InterviewSerializer < ActiveModel::Serializer
  delegate :current_user, to: :scope



  attributes :id, :appointment, :time_zone, :comment, :channel, :contact, :jobseeker_contact, :status, :updated_at,
             :interviewee, :interviewer_designation, :employer_zone, :duration, :jobseeker_reply,
             :job_application_status_change, :is_approved, :interview_status, :is_selected

  has_many :calls
  has_one :job
  has_one :jobseeker, through: :job_application_status_change, class_name: User, foreign_key: 'jobseeker_id'
  has_one :employer, through: :job_application_status_change, class_name: User, foreign_key: 'employer_id'
  has_one :company
  has_many :interview_committee_members

  def calls
    object.calls.where(user_id: current_user.id)
  end



  def appointment
    object.appointment.in_time_zone(self.time_zone)
  end

  def interviewee
    object.interviewee || object.interviewer.try(:full_name)
  end
end
