# # This file should contain all the record creation needed to seed the database with its default values.
# # The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
# #
# # Examples:
# #
# #   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
# #   Mayor.create(name: 'Emanuel', city: cities.first)

Dir[Rails.root.join('db/seeds/*.rb')].sort.each do |file|
  puts "Processing #{file.split('/').last}"
  require file
end

salary_ranges  = SalaryRange.create([
                                      {salary_from: 0, salary_to: 1000}, {salary_from: 1000, salary_to: 2000},
                                      {salary_from: 2000, salary_to: 3000},
                                      {salary_from: 3000, salary_to: 4000}, {salary_from: 4000, salary_to: 5000},
                                      {salary_from: 5000, salary_to: 6000}, {salary_from: 6000, salary_to: 7000},
                                      {salary_from: 7000, salary_to: 8000}, {salary_from: 8000, salary_to: 9000},
                                      {salary_from: 9000, salary_to: 10000}, {salary_from: 10000, salary_to: 900000}
                                    ]) if SalaryRange.count == 0

# alert_types    = AlertType.create([
#                                     {name: "Daily"},
#                                     {name: "Weekly"},
#                                     {name: "Monthly"},
#                                     {name: "None"}
#                                   ]) if AlertType.count == 0

visa_statuses  = VisaStatus.create([
                                     {name: "No Visa"},
                                     {name: "Tourist"},
                                     {name: "Resident Visa - Transferable"},
                                     {name: "Resident Visa - Non Transferable"},
                                     {name: "Citizen"}
                                   ]) if VisaStatus.count == 0

benefits       = Benefit.create([
                                  {name: "Medical Insurance", icon: "icon-medical-insurance"},
                                  {name: "Company Car", icon: "icon-car"},
                                  {name: "Flight Tickets", icon: "icon-flight-tickets"},
                                  {name: "Family Benefits", icon: "icon-family-benefits"},
                                  {name: "Graduates Programe", icon: "icon-graduates-programe"},
                                  {name: "Recreational Facilities", icon: "icon-facilities"},
                                  {name: "Pet Friendly Office", icon: "icon-pet-friendly"},
                                  {name: "Flexi Hours", icon: "icon-flexi"},
                                  {name: "Free Food", icon: "icon-free-food"},
                                  {name: "Company Activities", icon: "icon-activities"},
                                  {name: "Work From Home", icon: "icon-work-from"},
                                  {name: "Travel Opportunities", icon: "icon-travel"},
                                  {name: "Retirement Benefits", icon: "icon-retirement"},
                                  {name: "Stock Options & Equity", icon: "icon-stock"},
                                ]) if Benefit.count == 0

age_groups     = AgeGroup.create([
                                   {min_age: 18, max_age: 25},
                                   {min_age: 26, max_age: 30},
                                   {min_age: 31, max_age: 35},
                                   {min_age: 36, max_age: 40},
                                   {min_age: 41, max_age: 45},
                                   {min_age: 46, max_age: 50},
                                   {min_age: 51, max_age: 55},
                                   {min_age: 56, max_age: 60},
                                   {min_age: 60, max_age: 100}
                                 ]) if AgeGroup.count == 0

# certificates   = Certificate.create([
#                                       {name: "CCNA", weight: 10},
#                                       {name: "CCNP", weight: 10},
#                                       {name: "IELTS", weight: 10},
#                                       {name: "TOEFL", weight: 10}
#                                     ]) if Certificate.count == 0

experience_ranges = ExperienceRange.create([
                                               {experience_from: 0, experience_to: 2},
                                               {experience_from: 2, experience_to: 4},
                                               {experience_from: 4, experience_to: 6},
                                               {experience_from: 6, experience_to: 8},
                                               {experience_from: 8, experience_to: 10},
                                               {experience_from: 10, experience_to: 100}
                                           ]) if ExperienceRange.count == 0


# packages       = Package.create([
#                                     {name: "TryOut", description: "1-Month Package",price: 750 ,currency: "USD",job_postings: 5,db_access_days: 30,employer_logo: false,branding: true},
#                                     {name: "StatUp", description: "3-Months Package",price: 1750 ,currency: "USD",job_postings: 20,db_access_days: 90,employer_logo: false,branding: true},
#                                     {name: "BuildOn", description: "6-Months Package",price: 3000 ,currency: "USD",job_postings: 50,db_access_days: 180,employer_logo: true,branding: true},
#                                     {name: "GoBig", description: "12-Months Package",price: 5000 ,currency: "USD",job_postings: 5000,db_access_days: 360,employer_logo: true,branding: true}
#                                 ]) if Package.count == 0

# meta_tage     = MetaTag.create([
#                                   {page_name: "home", page_title: "BLOOVO.COM", meta_tags: "jobs, careers", img_alts: "jobs,careers", description: "The Science of Job Matching\nSearch for Jobs in the Middle East"},
#                                   {page_name: "jobs", page_title: "BLOOVO.COM", meta_tags: "jobs, careers", img_alts: "jobs,careers", description: "Jobs Page"}
#                                ]) if MetaTag.count == 0

# # FeaturedCompany
# FeaturedCompany.add_default_featured if FeaturedCompany.count == 0

# # Sectors:
sectos_names = ["Accounting & Auditing","Administration","Airlines","Airplane Manufacturing","Alternative Medicine","Aluminum Production & Distribution","Animation & Motion Pictures","Apparel & Fashion","Architecture","Arts and Crafts","Automotive Manufacturing","Aviation & Aerospace","Banking","Beauty, Salon, & Spa","Biotechnology","Building Materials","Business Consulting","Capital Markets","Chemicals","Civil Engineering","Commodity Trading","Computer & Network Security","Computer Games","Computer Hardware","Computer Networking","Computer Software","Conglomerate","Construction","Consumer Electronics","Cosmetics","Courier Services","Customer Service","Defense Services","E-Commerce","Education Management","E-Learning","Electrical/Electronic Manufacturing","Electricity Services","Energy & Alternative Energy","Engineering","Environmental Services","Events Management & Services","Facilities Management","Farming","Fashion & Design","Films","Fishery","Food & Beverages","Food Distribution","Food Manufacturing & Processing","Freight Forwarding & Cargo","Fund Raising","Furniture","Gaming","Glass, Ceramics & Concrete","Government Administration","Government Relations","Graphic Design","Health & Fitness","Hospitals & Clinics","Hotels & Resorts","Human Resources","Industrial Manufacturing","Insurance","International Affairs","Internet Services","Investment Banking","IT Services","Legal Services","Leisure, Travel & Tourism","Logistics","Logistics and Supply Chain","Luxury Goods & Jewelry","Machinery","Management Consulting","Market Research","Marketing and Advertising","Mechanical Manufacturing","Media","Media Broadcast","Medical Devices","Military Production","Mining & Metals","Motor Transport","Museums and Institutions","Music","Nanotechnology","Newspapers & Magazines","Oil & Gas","Online Media","Packaging and Containers","Petrochemicals","Pharmaceuticals & Pharmacies","Philanthropy","Photography","Plastics","Postal Services","Printing & Publishing","Private Equity & Venture Capital","Public Policy","Public Relations","Real Estate","Recreational Facilities and Services","Religious Institutions","Research & Development","Restaurants","Retail","Retail Distribution","Semiconductors","Shipbuilding","Shipping & Marine Services","Sporting Goods","Sports Training","Staffing and Recruiting","Steel Production & Distribution","Telecommunications","Textile Manufacturing","Tobacco","Transportation","Warehousing","Water Services","Wholesale"]
sectors_max_display_order = Sector.pluck(:display_order).max || 0
sectos_names.each do |sector_name|
  unless Sector.find_by_name(sector_name)
    sectors_max_display_order += 1
    Sector.create({name: sector_name, deleted: false, display_order: sectors_max_display_order})
  end
end

# # FunctionalArea:
functional_areas_names = ["Research & Development","Finance & Analysis","Operations","Administration","Support Services","Sales/Business Development","Human Resources","Information Technology","Strategy & Planning","Production","Marketing","Freelancing","Maintenance","Accounting & Auditing","Risk Management"]
functional_areas_max_display_order = FunctionalArea.pluck(:display_order).max || 0
functional_areas_names.each do |functional_name|
  unless FunctionalArea.find_by_area(functional_name)
    functional_areas_max_display_order += 1
    FunctionalArea.create({area: functional_name, deleted: false, display_order: functional_areas_max_display_order})
  end
end

# # Company Classification
# classifications = ["Limited Liability Company","Limited Partnership","Public Shareholding Company","Public Limited Company","Holding Company","Free Zone Company","Sole Proprietorship","State Owned Enterprises","Incorporated (Inc.)","Limited (Ltd.)","Non-Profit Organization","Other"]
# classifications.each do |classification|
#   unless CompanyClassification.find_by_name(classification)
#     CompanyClassification.create({name: classification, active: true, deleted: false})
#   end
# end

# # Job Types
# job_types = ["Internship","Part-Time","Full-Time","Contractual","Freelancer"]
# job_types.each do |job_type|
#   unless JobType.find_by_name(job_type)
#     JobType.create({name: job_type, display_order: JobType.count + 1})
#   end
# end

# # Email Templates for Interview
# file = File.read('db/email_templates.json')
# interview_templates = eval(file)
# interview_templates.each do |key, val|
#   key = key.to_s
#   next if EmailTemplate.find_by_name(key).present?
#   if key.index(',').present?
#     key.split(",").each do |k|
#       next if EmailTemplate.find_by_name(k).present?
#       EmailTemplate.create(name: k, body: val)
#     end
#   else
#     EmailTemplate.create(name: key, body: val)
#   end
# end

