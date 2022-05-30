# create_table "organization_types", force: :cascade do |t|
#     t.string   "name"
#     t.string   "ar_name"
#     t.integer  "order"
#     t.datetime "created_at", null: false
#     t.datetime "updated_at", null: false
#   end

OrganizationType.find_or_create_by(name: 'Executive Office') do |type|
    type.id = 1,
    type.ar_name = 'المكتب التنفيذي',
    type.order = 1
end

OrganizationType.find_or_create_by(name: 'Agency') do |type|
    type.id = 2,
    type.ar_name = 'الوكالة',
    type.order = 2
end

OrganizationType.find_or_create_by(name: 'General Department') do |type|
    type.id = 3,
    type.ar_name = 'الإدارة عامة',
    type.order = 3
end

OrganizationType.find_or_create_by(name: 'Department') do |type|
    type.id = 4,
    type.ar_name = 'الإدارة',
    type.order = 4
end

OrganizationType.find_or_create_by(name: 'Center') do |type|
    type.id = 5,
    type.ar_name = 'المركز',
    type.order = 5
end

OrganizationType.find_or_create_by(name: 'Section') do |type|
    type.id = 6,
    type.ar_name = 'قسم',
    type.order = 6
end

OrganizationType.find_or_create_by(name: 'Unit') do |type|
    type.id = 7,
    type.ar_name = 'الوحدة',
    type.order = 7
end
