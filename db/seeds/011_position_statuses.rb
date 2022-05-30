postion_statuses = [
    {
        name: "Budgeted",
        ar_name: "المدرجة في الميزانية",
    },
    {
        name: "Not Budgeted",
        ar_name: "غير مدرجة في الميزانية",
    }
]

postion_statuses.each do |status|
    unless PositionStatus.find_by_name(status[:name])
        PositionStatus.create(status)
   end
end