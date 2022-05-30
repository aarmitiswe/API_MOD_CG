job_experience_levels = [
  {
    level: "Junior Level",
    ar_level: "خبرة بسيطة", 
    display_order: 1,
    deleted: false
  },
  {
    level: "Senior Level",
    ar_level: "خبرة متقدمة", 
    display_order: 3,
    deleted: false
  },
  {
    level: "Management",
    ar_level: "إدارة عليا",
    display_order: 4,
    deleted: false
  },
  {
    level: "Mid-Level",
    ar_level: "خبرة متوسطة",
    display_order: 2,
    deleted: false
  },
  {
    level: "Executive Management Level",
    ar_level: "خبرة في الإدارة التنفيذية ",
    display_order: 5,
    deleted: false
  },
]

job_experience_levels.each do |level|
  unless JobExperienceLevel.find_by_level(level[:level])
   JobExperienceLevel.create(level)
 end
end


