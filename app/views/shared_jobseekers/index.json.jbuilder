json.array!(@shared_jobseekers) do |shared_jobseeker|
  json.extract! shared_jobseeker, :id, :sender_id, :receiver_id, :jobseeker_id
  json.url shared_jobseeker_url(shared_jobseeker, format: :json)
end
