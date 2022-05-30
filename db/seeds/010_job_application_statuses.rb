job_application_statuses = [
  {
    id: 1,
    status: "Applied",
    order: 1,
    ar_status: "قائمة المتقدمين"
  },
  {
    id: 2,
    status: "Shortlisted",
    order: 2,
    ar_status: "القائمة المختصرة",
  },
  {
    id: 3,
    status: "Shared",
    order: 3,
    ar_status: "القائمة المشاركة",
  },
  {
    id: 4,
    status: "Selected",
    order: 4,
    ar_status: "القائمة المُختارة",
  },
  {
    id: 5,
    status: "Interview",
    order: 5,
    ar_status: "مرحلة المقابلة",
  },
  {
    id: 6,
    status: "PassInterview",
    order: 6,
    ar_status: "مجتازو المقابلة",
  },
  {
    id: 7,
    status: "SecurityClearance",
    order: 7,
    ar_status: "التزكية الأمنية",
  },
  {
    id: 8,
    status: "Assessment",
    order: 8,
    ar_status: "التقييم",
  },
  {
    id: 9,
    status: "Offering",
    order: 9,
    ar_status: "تحت العرض",
  },
  {
    id: 10,
    status: "Onboarding",
    order: 10,
    ar_status: "مرحلة التهيئة",
  },
  {
    id: 11,
    status: "Unsuccessful",
    order: 11,
    ar_status: "القائمة الغير ناجحة",
  },
  {
    id: 12,
    status: "Hired",
    order: 12,
    ar_status: "القائمة الناجحة",
  }
]

job_application_statuses.each do |status|
  unless JobApplicationStatus.find_by_status(status[:status])
   JobApplicationStatus.create(status)
 end
end
