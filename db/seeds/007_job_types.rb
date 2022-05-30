job_types = [
  "Part-Time",
  "Full-Time",
  "Contractual",
  "Freelancer"
]

job_types.each do |job_type|
 unless JobType.find_by_name(job_type)
   JobType.create({name: job_type, display_order: JobType.count + 1})
 end
end
