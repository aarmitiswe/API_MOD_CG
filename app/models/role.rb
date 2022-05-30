class Role < ActiveRecord::Base
  has_many :users, dependent: :nullify

  # ROLES = %w(company_owner company_admin company_user recruiter hiring_manager recruitment_manager)
  ROLES = [
      'Super Admin', 'Recruiter', 'Hiring Manager', 'Recruitment Manager', 'Interviewer', 'Security Clearance Officer',
      'Assessor_Coordinator', 'On-Boarding Team Member', 'Sourcing Team', 'Jobseeker','QEC_Coordinator', 'Assessor',
      "Onboarding Manager", "On-Boarding Support Management System Representative",
      "On-Boarding Performance Evaluation Representative", "On-Boarding MOD Session Representative", "General Department Recruitment Officer"
  ]

  ON_BOARDING_ROLES = ["Onboarding Manager", "On-Boarding Support Management System Representative",
                       "On-Boarding Performance Evaluation Representative", "On-Boarding MOD Session Representative"]

  # Role.all.each{ |role| Object.const_set(role.name.upcase.gsub(/[\ \-]/, '_'), role.name)}
  ROLES.each{ |role| Object.const_set(role.upcase.gsub(/[\ \-]/, '_'), role)}

  # Object.const_set('SUPER_ADMIN', 42)
  #
  def self.create_roles
    ROLES.each{|role| Role.find_or_create_by(name: role)}
  end

  scope :onboarding_team, -> { where(name: ["Onboarding Manager", "On-Boarding Support Management System Representative", "On-Boarding Performance Evaluation Representative", "On-Boarding MOD Session Representative"]) }

  def self.add_new_roles
    Role.find_or_create_by(name: "QEC_Coordinator", ar_name: "منسق التقييم")
    Role.find_or_create_by(name: "Assessor", ar_name: "مقيّم")
    Role.find_by_name("Coordinator").update(name: "Assessor_Coordinator", ar_name: "منسق المستشار") if Role.find_by_name("Coordinator").present?
    Role.find_or_create_by(name: "Assessor_Coordinator", ar_name: "منسق المستشار")

    Role.find_by_name('Onboarding').update(name: 'Onboarding Manager') if Role.find_by_name('Onboarding').present?

    Role.find_or_create_by(name: "Onboarding Manager", ar_name: "مدير لبرنامج التهيئة الوظيفية")
    Role.find_or_create_by(name: "On-Boarding Support Management System Representative", ar_name: "ممثل الإدارة العامه للدعم الإداري لبرنامج التهيئة الوظيفية")
    Role.find_or_create_by(name: "On-Boarding Performance Evaluation Representative", ar_name: "ممثل تقييم الأداء الوظيفي لبرنامج التهيئة الوظيفية")
    Role.find_or_create_by(name: "On-Boarding MOD Session Representative", ar_name: "ممثل برنامج التهيئة الوظيفية")
  end

end
