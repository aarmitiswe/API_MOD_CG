job_statuses = [
  {status: "Under Approval" , ar_status: "تحت الموافقة"},
  {status: "Open", ar_status: "متاحة"},
  {status: "Closed", ar_status: "مغلقة"},
]

job_statuses.each do |job_status|
  unless JobStatus.find_by_status(job_status[:status])
   JobStatus.create({ status: job_status[:status], ar_status: job_status[:ar_status]})
 end
end

