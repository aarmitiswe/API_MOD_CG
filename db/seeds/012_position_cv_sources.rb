postion_cv_sources = [
    {
        name: "Hiring Manager",
        ar_name: "مدير الإدارة", 
    },
    {
        name: "Sourcing Team",
        ar_name: "فريق الاستقطاب", 
    },
    {
        name: "Tomoh",
        ar_name: "طموح", 
    },
]

postion_cv_sources.each do |source|
    unless PositionCvSource.find_by_name(source[:name])
        PositionCvSource.create(source)
   end
end