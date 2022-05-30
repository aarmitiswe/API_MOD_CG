cities = [
    {
        name: "Abha",
        country_id: 1,
        ar_name: "أبها"
    },
    {
        name: "Al Kharj",
        country_id: 1,
        ar_name: "الخرج"
    },
    {
        name: "Aseer",
        country_id: 1,
        ar_name: "عسير"
    },
    {
        name: "Buraidah",
        country_id: 1,
        ar_name: "بريدة"
    },
    {
        name: "Dammam",
        country_id: 1,
        ar_name: "الدمام"
    },
    {
        name: "Hafar Al-Batin",
        country_id: 1,
        ar_name: "حفر الباطن"
    },
    {
        name: "Hail",
        country_id: 1,
        ar_name: "حايل"
    },
    {
        name: "Hofuf",
        country_id: 1,
        ar_name: "الهفوف"
    },
    {
        name: "Jeddah",
        country_id: 1,
        ar_name: "جدة"
    },
    {
        name: "Jizan",
        country_id: 1,
        ar_name: "جيزان"
    },
    {
        name: "Khamis Mushait",
        country_id: 1,
        ar_name: "خميس مشيط"
    },
    {
        name: "Khobar",
        country_id: 1,
        ar_name: "الخبر"
    },
    {
        name: "Mecca",
        country_id: 1,
        ar_name: "مكة"
    },
    {
        name: "Medina",
        country_id: 1,
        ar_name: "المدينة المنورة"
    },
    {
        name: "Najran",
        country_id: 1,
        ar_name: "نجران"
    },
    {
        name: "Qatif",
        country_id: 1,
        ar_name: "القطيف"
    },
    {
        name: "Riyadh",
        country_id: 1,
        ar_name: "الرياض"
    },
    {
        name: "Tabuk",
        country_id: 1,
        ar_name: "تبوك"
    },
    {
        name: "Taif",
        country_id: 1,
        ar_name: "الطائف"
    },
    {
        name: "Yanbu",
        country_id: 1,
        ar_name: "ينبع"
    }
]

cities.each do |city|
    unless City.find_by_name(city[:name])
        City.create(city)
   end
end