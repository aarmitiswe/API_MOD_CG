Role.find_or_create_by(name: 'Super Admin')

Role.find_or_create_by(name: 'Recruiter') do |role|
    role.ar_name = 'مسؤول التوظيف'
end

Role.find_or_create_by(name: 'Hiring Manager') do |role|
    role.ar_name = '"مدير إدارة/ قسم'
end

Role.find_or_create_by(name: 'Recruitment Manager') do |role|
    role.ar_name = 'مدير التوظيف'
end

Role.find_or_create_by(name: 'Interviewer') do |role|
    role.ar_name = 'مجري المقابلة الشخصية'
end

Role.find_or_create_by(name: 'Security Officer') do |role|
    role.ar_name = 'مسؤول التزكية الأمنية'
end

Role.find_or_create_by(name: 'Coordinator') do |role|
    role.ar_name = 'المنسق'
end

Role.find_or_create_by(name: 'QEC_Coordinater') do |role|
    role.ar_name = 'منسق التقييم'
end

Role.find_or_create_by(name: 'On-Boarding Team Member') do |role|
    role.ar_name = 'فريق التهيئة/ما بعد التوظيف'
end

Role.find_or_create_by(name: 'Sourcing Team') do |role|
    role.ar_name = 'فريق بحث السير الذاتية'
end

Role.find_or_create_by(name: 'Jobseeker') do |role|
    role.ar_name = 'باحث عن عمل'
end
