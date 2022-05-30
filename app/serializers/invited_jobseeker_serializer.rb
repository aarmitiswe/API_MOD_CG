class InvitedJobseekerSerializer < ActiveModel::Serializer
  attributes :id, :jobseeker_id, :job_id, :msg_content
end
