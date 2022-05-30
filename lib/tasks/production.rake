require 'net/http'
require 'json'

require 'smarter_csv'
require 'date'
require 'pp'

require 'helpers/data_converter'

def build_requisition(eval_form_list, eval_question_hash)
  eval_form_list.each do |sel_form|
    form_obj = EvaluationForm.where('lower(name) = ?', sel_form).first
    if form_obj.nil?
      form_obj = EvaluationForm.create(name: sel_form)
      puts "Created Form " + sel_form
    end
    eval_question_hash[sel_form].each do |sel_question|
      question_obj = form_obj.evaluation_questions.where('lower(name) = ?', sel_question).first
      if question_obj.nil?
        form_obj.evaluation_questions.create(name: sel_question, description: sel_question)
        puts "Created Question " + sel_question + " for Form " + sel_form
      end
    end

  end
end

namespace :production do
  desc 'Remove ISPG from DB'
  task remove_ispg_accounts: :environment do
    no_need_users = [
        "deepa_vp@ispg.in","saranya_sasidharan@ispg.in","jubyjoseph@ispg.in","jobin_joseph@ispg.in",
        "anoopispg@gmail.com","jubyjoseph1@ispg.in","renju_sasidharan@ispg.in","boney_mathew@ispg.in",
        "devisree_raj@ispg.in","saranyatestispg@gmail.com","jinu@ispg.in","jubyjoseph2@ispg.in","anoop@ispg.co.in",
        "byju_m@ispg.in","jinu@ispg.co.in","shameem@ispg.in","jijo_thomas@ispg.in","aswathy_mp@ispg.in",
        "ispguser1@gmail.com","lostispg@yahoo.in","naiju_jose@ispg.in","athul_ms@ispg.in","juby12@ispg.in",
        "juby1@ispg.in","karthika_tk@ispg.in","suja@ispg.in","ispguser2@gmail.com","ratheesh@ispg.co.in"
    ]

    User.where(email: no_need_users).each do |u|
      u.destroy!
    end
  end

  desc 'clean testing companies'
  task clean_testing_companies: :environment do
    companies_names = ["Nitha Testing Company", "Deepa Testing company1", "Ispg test"]
    Company.active.where(name: companies_names).each do |com|
      com.update_attribute(:active, false)
      com.jobs.update_attribute(active: false)
      com.users.update_all(active: false)
    end
  end

  desc 'clean reset all passwords'
  task reset_all_passwords: :environment do

    User.active.where("id > 25544 AND id <= 71271").order(id: :asc).limit(10000).each do |u|
      u.delay.send_reset_password_instructions
    end
  end

  desc 'reset all job application status orders'
  task reset_all_job_appplication_status_orders: :environment do
    puts "Started re ordering"
    list_status = [ "Applied", "Reviewed", "Shortlisted", "Interview", "Selected", "UnderOffer", "AcceptOffer","Hired","Successful","Unsuccessful"]
    list_ar_status = ["قائمة المتقدمين", "مرحلة المراجعة","القائمة المختصرة","مرحلة المقابلة","القائمة المُختارة","تحت العرض","اقبل العرض","القائمة الناجحة","القائمة الناجحة","القائمة غير الناجحة"]
    list_status_order = [1,2,3,4,5,6,7,8,9,10]
    list_status.each_with_index do |sel_status, sel_status_index|
      sel_status_obj = JobApplicationStatus.find_or_create_by(status: sel_status)
      sel_status_obj.update(ar_status: list_ar_status[sel_status_index], order: list_status_order[sel_status_index])
    end

    puts "Finished re ordering"

  end

  desc 'Add value of last active'
  task update_last_active: :environment do
    User.where(last_active: nil).first(10000).each do |user|
      if user.is_jobseeker?
        last_active = [user.updated_at, user.last_sign_in_at, user.jobseeker.updated_at,
                       user.jobseeker.job_applications.pluck(:created_at),
                       user.jobseeker.saved_jobs.pluck(:created_at),
                       user.jobseeker.jobseeker_experiences.pluck(:created_at),
                       user.jobseeker.jobseeker_educations.pluck(:created_at),
                       user.jobseeker.company_followers.pluck(:created_at)].flatten.max

        user.update_column(:last_active, last_active)

        if user.jobseeker.is_completed? && (user.last_active.to_date - user.last_sign_in_at.to_date).to_i > 0
          puts "Push to Algolia #{user.email}"
          # TODO: Push to algloia not working in delayed jobs
          # user.jobseeker.push_to_algolia
        end
      elsif user.is_employer? && user.company.present?
        last_active = [user.updated_at, user.last_sign_in_at, user.company.jobs.pluck(:updated_at)].flatten.max
        user.update_column(:last_active, last_active)
      else
        puts user.email
      end
    end

    puts "======    Count Jobseekers with last active = #{User.where(last_active: nil).count} ============"
  end

  desc "Update Algolia for deactivate jobseekers"
  task update_non_active_users: :environment do
    User.jobseekers.where("updated_at >= (?) AND (active = (?) OR deleted = (?))", Date.today - 6.months, false, true).each do |user|
      # user.jobseeker.push_to_algolia
    end
    puts "Done Update Algolia"
  end

  desc "Update experience_range in Jobseeker"
  task update_experience_range_in_jobseeker: :environment do
    ExperienceRange.all.each do |exp_range|
      Jobseeker.where("years_of_experience >= ? AND years_of_experience <= ?", exp_range.experience_from, exp_range.experience_to).update_all(experience_range_id: exp_range.id)
    end
  end

  desc "Update salary_range in Jobseeker"
  task update_salary_range_in_jobseeker: :environment do
    SalaryRange.all.each do |salary_range|
      Jobseeker.where("current_salary >= ? AND current_salary <= ?", salary_range.salary_from, salary_range.salary_to).update_all(current_salary_range_id: salary_range.id)
      Jobseeker.where("expected_salary >= ? AND expected_salary <= ?", salary_range.salary_from, salary_range.salary_to).update_all(expected_salary_range_id: salary_range.id)
    end
  end

  desc "Add Evaluation Forms Tawuniya"
  task add_evaluation_forms_tawniya: :environment do
   eval_form_list = %w(fresh_evaluation advanced_evaluation advanced_leadership_evaluation)
   eval_question_hash = {}
   eval_question_hash['fresh_evaluation'] = %w(education_background prior_work_experience candidate_understanding_position
                            candidate_enthusiam english_level organization_fit overall_impression others score
                            comment recommendation post_guideline)


   eval_question_hash['advanced_evaluation'] = %w(client_focus continuous_improvement_focus
                                knowledge_market_business
                                problem_solving_decision_maker team_work technical_response technical_skills_relevance
                                remarkable_achievements total member_name_one member_position_one member_signature_one
                                member_name_two member_position_two member_signature_two recommendation)


   eval_question_hash['advanced_leadership_evaluation'] = %w(client_focus continuous_improvement_focus
                                        knowledge_market_business
                                        problem_solving_decision_maker team_work building_team
                                        direction_setting_execution communication_negotiation technical_response
                                        technical_skills_relevance remarkable_achievements total member_name_one
                                        member_position_one member_signature_one member_name_two member_position_two
                                        member_signature_two recommendation)


   build_requisition(eval_form_list, eval_question_hash)

   puts "Done Creating Evaluation Forms"
  end

  desc "Add Evaluation Forms Neom"
  task add_evaluation_forms_neom: :environment do
   eval_form_list = %w(interview_evaluation)
   eval_question_hash = {}

   eval_question_hash['interview_evaluation'] = %w(rating_scale work_experience_rating work_experience_comment
            education_rating education_comment technical_competence_rating technical_competence_comment
            personality_rating personality_comment personality_leadership_rating personality_leadership_comment maturity_rating
            maturity_comment attitude_leadership_rating attitude_leadership_comment communication_rating communication_comment
            total_score interview_comment recommendation hr_comment hr_signature)

   build_requisition(eval_form_list, eval_question_hash)

   puts "Done Creating Evaluation Forms"
  end


  desc "Add Evaluation Forms Riyadbank"
  task add_evaluation_forms_riyadbank: :environment do
    eval_form_list = %w(interview_evaluation_two)
    eval_question_hash = {}

    eval_question_hash['interview_evaluation_two'] = %w(technical_competence_rating technical_competence_comment
           drive_to_results_rating drive_to_results_comment customer_orientation_rating customer_orientation_comment
           capability_building_rating capability_building_comment teamwork_rating teamwork_comment eng_lang_rating
           eng_lang_comment overall_assessment justification signature)

    build_requisition(eval_form_list, eval_question_hash)

    puts "Done Creating Evaluation Forms"
  end

  desc "Add Evaluation Forms Medgulf"
  task add_evaluation_forms_medgulf: :environment do
    eval_form_list = %w(interview_evaluation_mg)
    eval_question_hash = {}


    eval_question_hash['interview_evaluation_mg'] = %w(academic experiences english computer training appearance
        communication relationship_building teamwork negotiation
       problem_solving self_confidence initiative creativity_innovation learning flexibility_adaptability
       follow_up_coordination customer_service_orientation strategic_thinking decision_making planning_organizing
       concern_for_quality_safety coaching_mentoring cost_consciousness academic_result experiences_result english_result
       computer_result training_result appearance_result communication_result relationship_building_result teamwork_result negotiation_result
      problem_solving_result self_confidence_result initiative_result creativity_innovation_result learning_result flexibility_adaptability_result
      follow_up_coordination_result customer_service_orientation_result strategic_thinking_result decision_making_result planning_organizing_result
      concern_for_quality_safety_result coaching_mentoring_result cost_consciousness_result recommendation)



    build_requisition(eval_form_list, eval_question_hash)

    puts "Done Creating Evaluation Forms for Medgulf"
  end



  desc "Set Branches Table"
  task fill_branches_table: :environment do
    company = Company.first
    origin_path = "#{Rails.root}/public/ATS/Branches/Zamil/"
    branches = [
        {name: "Arabian Gulf Construction", ar_name: "الخليج العربي للانشاءات", avatar_path: "1.png", ar_avatar_path: "1-ar.png"},
        {name: "Zamil Architectural Industries", ar_name: "الزامل للصناعات المهمارية", avatar_path: "2.png", ar_avatar_path: "2-ar.png"},
        {name: "Zamil Food Industries", ar_name: "الزامل للصناعات الغذائيه", avatar_path: "3.png", ar_avatar_path: "3-ar.png"},
        {name: "Zamil Group", ar_name: "مجموعة الزامل", avatar_path: "4.png", ar_avatar_path: "4-ar.png"},
        {name: "Zamil Industrial Coating", ar_name: "الزامل للطلاء الصناعي", avatar_path: "5.png", ar_avatar_path: "5-ar.png"},
        {name: "Zamil Info Services", ar_name: "الزامل خدمات المعلومات", avatar_path: "6.png", ar_avatar_path: "6-ar.png"},
        {name: "Zamil Investment", ar_name: "الزامل للاستثمار", avatar_path: "7.png", ar_avatar_path: "7-ar.png"},
        {name: "Zamil Ladders", ar_name: "الزامل للسلالم", avatar_path: "8.png", ar_avatar_path: "8-ar.png"},
        {name: "Zamil Operations & Maintenace", ar_name: "الزامل للصيانة والتشغيل", avatar_path: "9.png", ar_avatar_path: "9-ar.png"},
        {name: "Zamil Offshore", ar_name: "الزامل البحرية", avatar_path: "10.png", ar_avatar_path: "10-ar.png"},
        {name: "Zamil Plastic", ar_name: "الزامل بلاستيك", avatar_path: "11.png", ar_avatar_path: "11-ar.png"},
        {name: "Zamil Private Office", ar_name: "الزامل مكتب العائلة", avatar_path: "12.png", ar_avatar_path: "12-ar.png"},
        {name: "Zamil Real Estate", ar_name: "الزامل العقارية", avatar_path: "13.png", ar_avatar_path: "13-ar.png"},
        {name: "Zamil Shade", ar_name: "الزامل مظلات", avatar_path: "14.png", ar_avatar_path: "14-ar.png"},
        {name: "Zamil Shipyard", ar_name: "الزامل لبناء واصلاح السفن", avatar_path: "15.png", ar_avatar_path: "15-ar.png"},
        {name: "Zamil Trade & Services", ar_name: "الزامل التجارة والخدمات", avatar_path: "16.png", ar_avatar_path: "16-ar.png"},
        {name: "Zamil Travel", ar_name: "الزامل للسفريات", avatar_path: "17.png", ar_avatar_path: "17-ar.png"},
    ]

    branches.each do |branch_obj|

      branch = Branch.find_or_create_by(name: branch_obj[:name], ar_name: branch_obj[:ar_name], company_id: company.id)
      Branch::UploadAvatar.new(branch, "#{origin_path}#{branch_obj[:avatar_path]}", "#{origin_path}#{branch_obj[:ar_avatar_path]}").perform
    end
  end


  desc "Update Grades"
  task upload_grades: :environment do
    ([1,2,3,4,5,6,7,8,9,10,11,12,13]).map{|cnt| Grade.find_by_name("Level #{cnt}").update(name: "Grade #{cnt}") if Grade.find_by_name("Level #{cnt}")}
    ([1,2,3,4,5,6,7,8,9,10]).map{|cnt| Grade.find_or_create_by(name: "Grade #{cnt}")}

    puts "All Grades have been updated"
  end
end