# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20220410103705) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "age_groups", force: :cascade do |t|
    t.integer  "min_age"
    t.integer  "max_age"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "alert_types", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "ar_name"
  end

  create_table "assessments", force: :cascade do |t|
    t.string   "assessment_type"
    t.string   "status"
    t.text     "comment"
    t.string   "document_report_file_name"
    t.string   "document_report_content_type"
    t.integer  "document_report_file_size"
    t.datetime "document_report_updated_at"
    t.integer  "user_id"
    t.integer  "job_application_status_change_id"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "assessments", ["job_application_status_change_id"], name: "index_assessments_on_job_application_status_change_id", using: :btree
  add_index "assessments", ["user_id"], name: "index_assessments_on_user_id", using: :btree

  create_table "assigned_folders", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "folder_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "assigned_folders", ["folder_id"], name: "index_assigned_folders_on_folder_id", using: :btree
  add_index "assigned_folders", ["user_id"], name: "index_assigned_folders_on_user_id", using: :btree

  create_table "bank_accounts", force: :cascade do |t|
    t.integer  "jobseeker_id"
    t.string   "account_number"
    t.string   "iban_number"
    t.string   "bank_name"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "bank_accounts", ["jobseeker_id"], name: "index_bank_accounts_on_jobseeker_id", using: :btree

  create_table "benefits", force: :cascade do |t|
    t.string   "name"
    t.string   "icon"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "ar_name"
  end

  create_table "blog_tags", force: :cascade do |t|
    t.integer  "blog_id"
    t.integer  "tag_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "blog_tags", ["blog_id"], name: "index_blog_tags_on_blog_id", using: :btree
  add_index "blog_tags", ["tag_id"], name: "index_blog_tags_on_tag_id", using: :btree

  create_table "blogs", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.boolean  "is_active"
    t.boolean  "is_deleted"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "video_file_name"
    t.string   "video_content_type"
    t.integer  "video_file_size"
    t.datetime "video_updated_at"
    t.string   "video_link"
    t.string   "image_file"
    t.integer  "views_count"
    t.integer  "downloads_count"
    t.integer  "company_user_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "blogs", ["company_user_id"], name: "index_blogs_on_company_user_id", using: :btree

  create_table "boarding_forms", force: :cascade do |t|
    t.string   "title"
    t.string   "owner_position"
    t.integer  "job_application_id"
    t.date     "effective_joining_date"
    t.string   "copy_number"
    t.date     "expected_joining_date"
    t.string   "signed_joining_document_file_name"
    t.string   "signed_joining_document_content_type"
    t.integer  "signed_joining_document_file_size"
    t.datetime "signed_joining_document_updated_at"
    t.string   "signed_stc_document_file_name"
    t.string   "signed_stc_document_content_type"
    t.integer  "signed_stc_document_file_size"
    t.datetime "signed_stc_document_updated_at"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.datetime "support_management_checked_at"
    t.datetime "evaluation_performance_checked_at"
    t.datetime "mod_session_checked_at"
    t.datetime "it_management_checked_at"
    t.datetime "business_service_management_checked_at"
    t.datetime "security_management_checked_at"
  end

  add_index "boarding_forms", ["job_application_id"], name: "index_boarding_forms_on_job_application_id", using: :btree

  create_table "boarding_requisitions", force: :cascade do |t|
    t.integer  "job_application_id"
    t.integer  "user_id"
    t.string   "status"
    t.integer  "boarding_form_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.text     "comment"
  end

  add_index "boarding_requisitions", ["boarding_form_id"], name: "index_boarding_requisitions_on_boarding_form_id", using: :btree
  add_index "boarding_requisitions", ["job_application_id"], name: "index_boarding_requisitions_on_job_application_id", using: :btree
  add_index "boarding_requisitions", ["user_id"], name: "index_boarding_requisitions_on_user_id", using: :btree

  create_table "branches", force: :cascade do |t|
    t.string   "name"
    t.string   "ar_name"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "ar_avatar_file_name"
    t.string   "ar_avatar_content_type"
    t.integer  "ar_avatar_file_size"
    t.datetime "ar_avatar_updated_at"
    t.integer  "company_id"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "branches", ["company_id"], name: "index_branches_on_company_id", using: :btree

  create_table "budgeted_vacancies", force: :cascade do |t|
    t.string   "job_title"
    t.string   "position_id"
    t.integer  "grade_id"
    t.integer  "job_experience_level_id"
    t.integer  "job_type_id"
    t.integer  "no_vacancies"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "section_id"
    t.integer  "unit_id"
    t.integer  "department_id"
    t.integer  "new_section_id"
  end

  add_index "budgeted_vacancies", ["department_id"], name: "index_budgeted_vacancies_on_department_id", using: :btree
  add_index "budgeted_vacancies", ["grade_id"], name: "index_budgeted_vacancies_on_grade_id", using: :btree
  add_index "budgeted_vacancies", ["job_experience_level_id"], name: "index_budgeted_vacancies_on_job_experience_level_id", using: :btree
  add_index "budgeted_vacancies", ["job_type_id"], name: "index_budgeted_vacancies_on_job_type_id", using: :btree
  add_index "budgeted_vacancies", ["new_section_id"], name: "index_budgeted_vacancies_on_new_section_id", using: :btree
  add_index "budgeted_vacancies", ["section_id"], name: "index_budgeted_vacancies_on_section_id", using: :btree
  add_index "budgeted_vacancies", ["unit_id"], name: "index_budgeted_vacancies_on_unit_id", using: :btree

  create_table "calls", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "interview_id"
    t.string   "token"
    t.integer  "duration"
    t.string   "room"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "calls", ["interview_id"], name: "index_calls_on_interview_id", using: :btree
  add_index "calls", ["user_id"], name: "index_calls_on_user_id", using: :btree

  create_table "candidate_information_documents", force: :cascade do |t|
    t.integer  "job_application_id"
    t.string   "title"
    t.string   "file_path"
    t.boolean  "default"
    t.boolean  "is_deleted"
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "document_two_file_name"
    t.string   "document_two_content_type"
    t.integer  "document_two_file_size"
    t.datetime "document_two_updated_at"
    t.string   "document_three_file_name"
    t.string   "document_three_content_type"
    t.integer  "document_three_file_size"
    t.datetime "document_three_updated_at"
    t.string   "name"
    t.string   "id_number"
    t.string   "job_title"
    t.string   "job_grade"
    t.string   "agency_id"
    t.string   "current_employer"
    t.integer  "job_application_status_change_id"
    t.string   "status"
    t.integer  "user_id"
    t.string   "document_four_file_name"
    t.string   "document_four_content_type"
    t.integer  "document_four_file_size"
    t.datetime "document_four_updated_at"
    t.string   "document_report_file_name"
    t.string   "document_report_content_type"
    t.integer  "document_report_file_size"
    t.datetime "document_report_updated_at"
    t.string   "document_passport_file_name"
    t.string   "document_passport_content_type"
    t.integer  "document_passport_file_size"
    t.datetime "document_passport_updated_at"
    t.string   "document_edu_cert_file_name"
    t.string   "document_edu_cert_content_type"
    t.integer  "document_edu_cert_file_size"
    t.datetime "document_edu_cert_updated_at"
    t.string   "document_national_address_file_name"
    t.string   "document_national_address_content_type"
    t.integer  "document_national_address_file_size"
    t.datetime "document_national_address_updated_at"
    t.string   "document_training_cert_file_name"
    t.string   "document_training_cert_content_type"
    t.integer  "document_training_cert_file_size"
    t.datetime "document_training_cert_updated_at"
  end

  add_index "candidate_information_documents", ["job_application_id"], name: "index_candidate_information_documents_on_job_application_id", using: :btree
  add_index "candidate_information_documents", ["job_application_status_change_id"], name: "can_doc_index", using: :btree
  add_index "candidate_information_documents", ["user_id"], name: "index_candidate_information_documents_on_user_id", using: :btree

  create_table "career_fair_applications", force: :cascade do |t|
    t.integer  "jobseeker_id"
    t.integer  "career_fair_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "career_fair_applications", ["career_fair_id"], name: "index_career_fair_applications_on_career_fair_id", using: :btree
  add_index "career_fair_applications", ["jobseeker_id"], name: "index_career_fair_applications_on_jobseeker_id", using: :btree

  create_table "career_fairs", force: :cascade do |t|
    t.string   "title"
    t.integer  "country_id"
    t.integer  "city_id"
    t.string   "address"
    t.boolean  "active",                  default: true
    t.integer  "gender"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "logo_image_file_name"
    t.string   "logo_image_content_type"
    t.integer  "logo_image_file_size"
    t.datetime "logo_image_updated_at"
    t.boolean  "deleted",                 default: false
    t.date     "from"
    t.date     "to"
  end

  add_index "career_fairs", ["city_id"], name: "index_career_fairs_on_city_id", using: :btree
  add_index "career_fairs", ["country_id"], name: "index_career_fairs_on_country_id", using: :btree

  create_table "certificates", force: :cascade do |t|
    t.string   "name"
    t.integer  "weight"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cities", force: :cascade do |t|
    t.string   "name"
    t.decimal  "latitude",   precision: 10, scale: 6
    t.decimal  "longitude",  precision: 10, scale: 6
    t.integer  "state_id"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "country_id"
    t.string   "ar_name"
  end

  add_index "cities", ["country_id"], name: "index_cities_on_country_id", using: :btree
  add_index "cities", ["name"], name: "index_cities_on_name", using: :btree
  add_index "cities", ["state_id"], name: "index_cities_on_state_id", using: :btree

  create_table "comments", force: :cascade do |t|
    t.string   "content"
    t.boolean  "is_deleted"
    t.boolean  "is_active"
    t.integer  "user_id"
    t.integer  "blog_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "comments", ["blog_id"], name: "index_comments_on_blog_id", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "companies", force: :cascade do |t|
    t.string   "name"
    t.text     "summary"
    t.date     "establishment_date"
    t.string   "website"
    t.string   "profile_image"
    t.string   "hero_image"
    t.integer  "current_city_id"
    t.integer  "current_country_id"
    t.string   "address_line1"
    t.string   "address_line2"
    t.string   "phone"
    t.string   "fax"
    t.string   "contact_email"
    t.string   "po_box"
    t.string   "contact_person"
    t.string   "google_plus_page_url"
    t.string   "linkedin_page_url"
    t.string   "facebook_page_url"
    t.string   "twitter_page_url"
    t.boolean  "active"
    t.boolean  "deleted"
    t.integer  "sector_id"
    t.integer  "company_size_id"
    t.integer  "company_type_id"
    t.integer  "company_classification_id"
    t.datetime "created_at",                                                   null: false
    t.datetime "updated_at",                                                   null: false
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "cover_file_name"
    t.string   "cover_content_type"
    t.integer  "cover_file_size"
    t.datetime "cover_updated_at"
    t.string   "latitude"
    t.string   "longitude"
    t.integer  "country_id"
    t.integer  "city_id"
    t.integer  "total_male_employees"
    t.integer  "total_female_employees"
    t.string   "video_cover_screenshot_file_name"
    t.string   "video_cover_screenshot_content_type"
    t.integer  "video_cover_screenshot_file_size"
    t.datetime "video_cover_screenshot_updated_at"
    t.string   "video_our_management_file_name"
    t.string   "video_our_management_content_type"
    t.integer  "video_our_management_file_size"
    t.datetime "video_our_management_updated_at"
    t.string   "video_our_management_screenshot_file_name"
    t.string   "video_our_management_screenshot_content_type"
    t.integer  "video_our_management_screenshot_file_size"
    t.datetime "video_our_management_screenshot_updated_at"
    t.string   "owner_name"
    t.string   "owner_designation"
    t.boolean  "is_premium",                                   default: false
    t.string   "ar_name"
  end

  add_index "companies", ["city_id"], name: "index_companies_on_city_id", using: :btree
  add_index "companies", ["company_classification_id"], name: "index_companies_on_company_classification_id", using: :btree
  add_index "companies", ["company_size_id"], name: "index_companies_on_company_size_id", using: :btree
  add_index "companies", ["company_type_id"], name: "index_companies_on_company_type_id", using: :btree
  add_index "companies", ["country_id"], name: "index_companies_on_country_id", using: :btree
  add_index "companies", ["sector_id"], name: "index_companies_on_sector_id", using: :btree

  create_table "company_classifications", force: :cascade do |t|
    t.string   "name"
    t.boolean  "active"
    t.boolean  "deleted"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "ar_name"
  end

  create_table "company_countries", force: :cascade do |t|
    t.integer  "country_id"
    t.integer  "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "company_countries", ["company_id"], name: "index_company_countries_on_company_id", using: :btree
  add_index "company_countries", ["country_id"], name: "index_company_countries_on_country_id", using: :btree

  create_table "company_followers", force: :cascade do |t|
    t.integer  "company_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "jobseeker_id"
  end

  add_index "company_followers", ["jobseeker_id"], name: "index_company_followers_on_jobseeker_id", using: :btree

  create_table "company_last_year_revenues", force: :cascade do |t|
    t.string   "revenue"
    t.boolean  "deleted"
    t.integer  "display_order"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "company_members", force: :cascade do |t|
    t.string   "name"
    t.string   "position"
    t.string   "facebook_url"
    t.string   "twitter_url"
    t.string   "linkedin_url"
    t.string   "google_plus_url"
    t.integer  "company_id"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "video_file_name"
    t.string   "video_content_type"
    t.integer  "video_file_size"
    t.datetime "video_updated_at"
    t.string   "video_screenshot_file_name"
    t.string   "video_screenshot_content_type"
    t.integer  "video_screenshot_file_size"
    t.datetime "video_screenshot_updated_at"
  end

  add_index "company_members", ["company_id"], name: "index_company_members_on_company_id", using: :btree

  create_table "company_sizes", force: :cascade do |t|
    t.string   "size"
    t.integer  "display_order"
    t.boolean  "deleted",       default: false
    t.boolean  "active",        default: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "company_subscriptions", force: :cascade do |t|
    t.integer  "company_id"
    t.integer  "package_id"
    t.datetime "expires_at"
    t.integer  "job_posts_bank"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "activation_code"
    t.date     "activated_at"
    t.integer  "attempts",        default: 0
    t.datetime "lock_at"
  end

  create_table "company_types", force: :cascade do |t|
    t.string   "name"
    t.boolean  "deleted"
    t.boolean  "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "ar_name"
  end

  create_table "company_users", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "company_id"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "document_e_signature_file_name"
    t.string   "document_e_signature_content_type"
    t.integer  "document_e_signature_file_size"
    t.datetime "document_e_signature_updated_at"
  end

  add_index "company_users", ["company_id"], name: "index_company_users_on_company_id", using: :btree
  add_index "company_users", ["user_id"], name: "index_company_users_on_user_id", using: :btree

  create_table "countries", force: :cascade do |t|
    t.string   "name"
    t.string   "iso"
    t.decimal  "latitude",           precision: 10, scale: 6
    t.decimal  "longitude",          precision: 10, scale: 6
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.string   "nationality"
    t.string   "ar_name"
    t.string   "lookup_nationality"
  end

  add_index "countries", ["name"], name: "index_countries_on_name", unique: true, using: :btree

  create_table "country_geo_groups", force: :cascade do |t|
    t.integer  "country_id"
    t.integer  "geo_group_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "country_geo_groups", ["country_id"], name: "index_country_geo_groups_on_country_id", using: :btree
  add_index "country_geo_groups", ["geo_group_id"], name: "index_country_geo_groups_on_geo_group_id", using: :btree

  create_table "cultures", force: :cascade do |t|
    t.string   "title"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.integer  "company_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "cultures", ["company_id"], name: "index_cultures_on_company_id", using: :btree

  create_table "cybersource_payments", force: :cascade do |t|
    t.string   "payment_token"
    t.string   "card_type"
    t.string   "expiration_month"
    t.string   "expiration_year"
    t.string   "last_4"
    t.string   "decision"
    t.string   "auth_code"
    t.string   "auth_amount"
    t.datetime "auth_time"
    t.string   "reason_code"
    t.string   "auth_trans_ref_no"
    t.string   "bill_trans_ref_no"
    t.string   "pa_reason_code"
    t.string   "pa_enroll_veres_enrolled"
    t.text     "pa_proof_xml"
    t.string   "pa_enroll_e_commerce_indicator"
    t.string   "req_reference_number"
    t.string   "req_transaction_uuid"
    t.string   "req_profile_id"
    t.string   "transaction_id"
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "demo_requests", force: :cascade do |t|
    t.string   "company_name"
    t.string   "country"
    t.string   "contact_person"
    t.string   "phone_number"
    t.string   "email"
    t.string   "reason"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "departments", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "ar_name"
  end

  create_table "email_templates", force: :cascade do |t|
    t.string   "name",       default: "",    null: false
    t.text     "body",       default: "",    null: false
    t.boolean  "deleted",    default: false, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "employer_notifications", force: :cascade do |t|
    t.integer  "notifiable_id"
    t.string   "notifiable_type"
    t.integer  "user_id"
    t.string   "finished_action"
    t.string   "needed_action"
    t.integer  "email_template_id"
    t.string   "subject"
    t.text     "content"
    t.string   "status"
    t.string   "page_url"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "employer_notifications", ["email_template_id"], name: "index_employer_notifications_on_email_template_id", using: :btree
  add_index "employer_notifications", ["user_id"], name: "index_employer_notifications_on_user_id", using: :btree

  create_table "evaluation_answers", force: :cascade do |t|
    t.integer  "evaluation_submit_id"
    t.integer  "evaluation_question_id"
    t.text     "answer"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "evaluation_answers", ["evaluation_question_id"], name: "index_evaluation_answers_on_evaluation_question_id", using: :btree
  add_index "evaluation_answers", ["evaluation_submit_id"], name: "index_evaluation_answers_on_evaluation_submit_id", using: :btree

  create_table "evaluation_forms", force: :cascade do |t|
    t.string   "name"
    t.string   "ar_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "evaluation_questions", force: :cascade do |t|
    t.string   "name"
    t.string   "ar_name"
    t.text     "description"
    t.text     "ar_description"
    t.integer  "evaluation_form_id"
    t.string   "question_type"
    t.string   "answers_list",       default: [],              array: true
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "evaluation_questions", ["evaluation_form_id"], name: "index_evaluation_questions_on_evaluation_form_id", using: :btree

  create_table "evaluation_submit_requisitions", force: :cascade do |t|
    t.integer  "evaluation_form_id"
    t.integer  "evaluation_submit_id"
    t.integer  "job_application_id"
    t.integer  "organization_id"
    t.integer  "user_id"
    t.string   "status"
    t.boolean  "active"
    t.datetime "approved_at"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "evaluation_submit_requisitions", ["evaluation_form_id"], name: "index_evaluation_submit_requisitions_on_evaluation_form_id", using: :btree
  add_index "evaluation_submit_requisitions", ["evaluation_submit_id"], name: "index_evaluation_submit_requisitions_on_evaluation_submit_id", using: :btree
  add_index "evaluation_submit_requisitions", ["job_application_id"], name: "index_evaluation_submit_requisitions_on_job_application_id", using: :btree
  add_index "evaluation_submit_requisitions", ["organization_id"], name: "index_evaluation_submit_requisitions_on_organization_id", using: :btree
  add_index "evaluation_submit_requisitions", ["user_id"], name: "index_evaluation_submit_requisitions_on_user_id", using: :btree

  create_table "evaluation_submits", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "job_application_id"
    t.integer  "evaluation_form_id"
    t.text     "comment"
    t.decimal  "total_score"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "evaluation_submits", ["evaluation_form_id"], name: "index_evaluation_submits_on_evaluation_form_id", using: :btree
  add_index "evaluation_submits", ["job_application_id"], name: "index_evaluation_submits_on_job_application_id", using: :btree
  add_index "evaluation_submits", ["user_id"], name: "index_evaluation_submits_on_user_id", using: :btree

  create_table "event_visitors", force: :cascade do |t|
    t.string   "name"
    t.string   "company"
    t.string   "position"
    t.string   "department"
    t.string   "mobile_phone"
    t.string   "email"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "experience_ranges", force: :cascade do |t|
    t.integer  "experience_from"
    t.integer  "experience_to"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "featured_companies", force: :cascade do |t|
    t.integer  "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "featured_companies", ["company_id"], name: "index_featured_companies_on_company_id", using: :btree

  create_table "folders", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "level"
    t.integer  "creator_id"
    t.integer  "parent_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "functional_areas", force: :cascade do |t|
    t.string   "area",          default: "",    null: false
    t.integer  "display_order"
    t.boolean  "deleted",       default: false, null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "ar_area"
  end

  create_table "geo_groups", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "grades", force: :cascade do |t|
    t.integer  "company_id"
    t.string   "name"
    t.string   "ar_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "grades", ["company_id"], name: "index_grades_on_company_id", using: :btree

  create_table "hash_tags", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "hash_tags", ["name"], name: "index_hash_tags_on_name", unique: true, using: :btree

  create_table "hiring_manager_owners", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "hiring_manager_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "hiring_manager_owners", ["hiring_manager_id"], name: "index_hiring_manager_owners_on_hiring_manager_id", using: :btree
  add_index "hiring_manager_owners", ["user_id"], name: "index_hiring_manager_owners_on_user_id", using: :btree

  create_table "hiring_managers", force: :cascade do |t|
    t.integer  "section_id"
    t.integer  "office_id"
    t.integer  "department_id"
    t.integer  "unit_id"
    t.integer  "grade_id"
    t.integer  "approver_one_id"
    t.integer  "approver_two_id"
    t.integer  "approver_three_id"
    t.integer  "approver_four_id"
    t.integer  "approver_five_id"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.boolean  "deleted",             default: false
    t.integer  "num_approvers",       default: 4
    t.string   "hiring_manager_type", default: "job"
    t.integer  "new_section_id"
  end

  add_index "hiring_managers", ["department_id"], name: "index_hiring_managers_on_department_id", using: :btree
  add_index "hiring_managers", ["grade_id"], name: "index_hiring_managers_on_grade_id", using: :btree
  add_index "hiring_managers", ["new_section_id"], name: "index_hiring_managers_on_new_section_id", using: :btree
  add_index "hiring_managers", ["office_id"], name: "index_hiring_managers_on_office_id", using: :btree
  add_index "hiring_managers", ["section_id"], name: "index_hiring_managers_on_section_id", using: :btree
  add_index "hiring_managers", ["unit_id"], name: "index_hiring_managers_on_unit_id", using: :btree

  create_table "identities", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "identities", ["user_id"], name: "index_identities_on_user_id", using: :btree

  create_table "interview_committee_members", force: :cascade do |t|
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "interview_id"
    t.integer  "user_id"
  end

  add_index "interview_committee_members", ["interview_id"], name: "index_interview_committee_members_on_interview_id", using: :btree
  add_index "interview_committee_members", ["user_id"], name: "index_interview_committee_members_on_user_id", using: :btree

  create_table "interviews", force: :cascade do |t|
    t.datetime "appointment"
    t.string   "time_zone"
    t.string   "comment"
    t.string   "channel"
    t.string   "contact"
    t.integer  "job_application_status_change_id"
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.string   "jobseeker_contact"
    t.string   "status"
    t.string   "interviewee"
    t.string   "employer_zone"
    t.integer  "duration"
    t.text     "jobseeker_reply"
    t.integer  "interviewer_id"
    t.string   "interviewer_designation"
    t.boolean  "is_approved",                      default: false
    t.string   "interview_status"
    t.boolean  "is_selected",                      default: false
  end

  add_index "interviews", ["job_application_status_change_id"], name: "index_interviews_on_job_application_status_change_id", using: :btree

  create_table "invite_contacts", force: :cascade do |t|
    t.string   "contacts",   default: [],              array: true
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "invited_jobseekers", force: :cascade do |t|
    t.integer  "jobseeker_id"
    t.integer  "job_id"
    t.string   "msg_content"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "invited_jobseekers", ["job_id"], name: "index_invited_jobseekers_on_job_id", using: :btree
  add_index "invited_jobseekers", ["jobseeker_id"], name: "index_invited_jobseekers_on_jobseeker_id", using: :btree

  create_table "job_application_logs", force: :cascade do |t|
    t.string   "log_type"
    t.integer  "user_id"
    t.integer  "job_application_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "job_application_logs", ["job_application_id"], name: "index_job_application_logs_on_job_application_id", using: :btree
  add_index "job_application_logs", ["user_id"], name: "index_job_application_logs_on_user_id", using: :btree

  create_table "job_application_status_changes", force: :cascade do |t|
    t.integer  "job_application_id"
    t.integer  "job_application_status_id"
    t.integer  "employer_id"
    t.integer  "jobseeker_id"
    t.string   "comment"
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.boolean  "notify_jobseeker",            default: false
    t.boolean  "is_waiting",                  default: false
    t.string   "offer_requisition_status"
    t.string   "on_boarding_status"
    t.boolean  "watheeq",                     default: false
    t.boolean  "performance_evaluation",      default: false
    t.boolean  "on_boarding_session",         default: false
    t.boolean  "it_management",               default: false
    t.boolean  "business_service_management", default: false
    t.boolean  "security_management",         default: false
  end

  create_table "job_application_statuses", force: :cascade do |t|
    t.string   "status"
    t.integer  "order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "ar_status"
  end

  create_table "job_applications", force: :cascade do |t|
    t.integer  "job_id"
    t.integer  "job_application_status_id"
    t.integer  "jobseeker_coverletter_id"
    t.integer  "jobseeker_resume_id"
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.integer  "jobseeker_id"
    t.boolean  "shared_with_hiring_manager"
    t.string   "security_clearance_document"
    t.boolean  "is_security_cleared"
    t.integer  "candidate_information_document_id"
    t.integer  "security_clearance_result_document_id"
    t.integer  "user_id"
    t.string   "employment_type"
    t.string   "candidate_type"
    t.string   "extra_document_file_name"
    t.string   "extra_document_content_type"
    t.integer  "extra_document_file_size"
    t.datetime "extra_document_updated_at"
    t.string   "extra_document_title"
    t.boolean  "deleted",                               default: false
    t.datetime "terminated_at"
  end

  add_index "job_applications", ["job_application_status_id"], name: "index_job_applications_on_job_application_status_id", using: :btree
  add_index "job_applications", ["job_id"], name: "index_job_applications_on_job_id", using: :btree
  add_index "job_applications", ["jobseeker_coverletter_id"], name: "index_job_applications_on_jobseeker_coverletter_id", using: :btree
  add_index "job_applications", ["jobseeker_id"], name: "index_job_applications_on_jobseeker_id", using: :btree
  add_index "job_applications", ["jobseeker_resume_id"], name: "index_job_applications_on_jobseeker_resume_id", using: :btree
  add_index "job_applications", ["user_id"], name: "index_job_applications_on_user_id", using: :btree

  create_table "job_benefits", force: :cascade do |t|
    t.integer  "job_id"
    t.integer  "benefit_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "job_benefits", ["benefit_id"], name: "index_job_benefits_on_benefit_id", using: :btree
  add_index "job_benefits", ["job_id"], name: "index_job_benefits_on_job_id", using: :btree

  create_table "job_categories", force: :cascade do |t|
    t.string   "name",          default: "",    null: false
    t.integer  "display_order"
    t.boolean  "deleted",       default: false, null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "job_certificates", force: :cascade do |t|
    t.integer  "job_id"
    t.integer  "certificate_id"
    t.string   "required_grade"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "job_certificates", ["certificate_id"], name: "index_job_certificates_on_certificate_id", using: :btree
  add_index "job_certificates", ["job_id"], name: "index_job_certificates_on_job_id", using: :btree

  create_table "job_countries", force: :cascade do |t|
    t.integer  "job_id"
    t.integer  "country_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "job_countries", ["country_id"], name: "index_job_countries_on_country_id", using: :btree
  add_index "job_countries", ["job_id"], name: "index_job_countries_on_job_id", using: :btree

  create_table "job_educations", force: :cascade do |t|
    t.string   "level",        default: "",    null: false
    t.integer  "displayorder"
    t.boolean  "deleted",      default: false, null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "ar_level"
  end

  create_table "job_experience_levels", force: :cascade do |t|
    t.string   "level",         default: "",    null: false
    t.integer  "display_order"
    t.boolean  "deleted",       default: false, null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "ar_level"
  end

  create_table "job_geo_groups", force: :cascade do |t|
    t.integer  "job_id"
    t.integer  "geo_group_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "job_geo_groups", ["geo_group_id"], name: "index_job_geo_groups_on_geo_group_id", using: :btree
  add_index "job_geo_groups", ["job_id"], name: "index_job_geo_groups_on_job_id", using: :btree

  create_table "job_history", force: :cascade do |t|
    t.string   "job_action_type"
    t.integer  "user_id"
    t.integer  "job_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.jsonb    "record_data"
  end

  add_index "job_history", ["job_id"], name: "index_job_history_on_job_id", using: :btree
  add_index "job_history", ["user_id"], name: "index_job_history_on_user_id", using: :btree

  create_table "job_languages", force: :cascade do |t|
    t.integer  "job_id"
    t.integer  "language_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "job_languages", ["job_id"], name: "index_job_languages_on_job_id", using: :btree
  add_index "job_languages", ["language_id"], name: "index_job_languages_on_language_id", using: :btree

  create_table "job_matching_percentages", force: :cascade do |t|
    t.float    "country"
    t.float    "city"
    t.float    "sector"
    t.float    "job_type"
    t.float    "education_level"
    t.float    "years_of_experience"
    t.float    "experience_level"
    t.float    "job_title"
    t.float    "department"
    t.float    "skills_focus_summary"
    t.float    "expecting_salary"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "job_recruiters", force: :cascade do |t|
    t.integer  "job_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "job_requests", force: :cascade do |t|
    t.integer  "job_id"
    t.integer  "hiring_manager_id"
    t.integer  "total_number_vacancies"
    t.string   "status_approval_one"
    t.string   "status_approval_two"
    t.string   "status_approval_three"
    t.string   "status_approval_four"
    t.string   "status_approval_five"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.date     "date_approval_one"
    t.date     "date_approval_two"
    t.date     "date_approval_three"
    t.date     "date_approval_four"
    t.date     "date_approval_five"
    t.string   "rejection_reason_one"
    t.string   "rejection_reason_two"
    t.string   "rejection_reason_three"
    t.string   "rejection_reason_four"
    t.string   "rejection_reason_five"
    t.boolean  "deleted"
    t.boolean  "request_for_approval",   default: false
    t.integer  "grade_id"
    t.string   "position_id"
    t.string   "status_approval_final"
    t.integer  "budgeted_vacancy_id"
    t.integer  "organization_id"
  end

  add_index "job_requests", ["budgeted_vacancy_id"], name: "index_job_requests_on_budgeted_vacancy_id", using: :btree
  add_index "job_requests", ["grade_id"], name: "index_job_requests_on_grade_id", using: :btree
  add_index "job_requests", ["hiring_manager_id"], name: "index_job_requests_on_hiring_manager_id", using: :btree
  add_index "job_requests", ["job_id"], name: "index_job_requests_on_job_id", using: :btree
  add_index "job_requests", ["organization_id"], name: "index_job_requests_on_organization_id", using: :btree

  create_table "job_skills", force: :cascade do |t|
    t.integer  "job_id"
    t.integer  "skill_id"
    t.integer  "level"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "job_skills", ["job_id"], name: "index_job_skills_on_job_id", using: :btree
  add_index "job_skills", ["skill_id"], name: "index_job_skills_on_skill_id", using: :btree

  create_table "job_statuses", force: :cascade do |t|
    t.string   "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "ar_status"
  end

  create_table "job_tags", force: :cascade do |t|
    t.integer  "job_id"
    t.integer  "tag_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "job_tags", ["job_id"], name: "index_job_tags_on_job_id", using: :btree
  add_index "job_tags", ["tag_id"], name: "index_job_tags_on_tag_id", using: :btree

  create_table "job_types", force: :cascade do |t|
    t.string   "name",          default: "",    null: false
    t.integer  "display_order"
    t.boolean  "deleted",       default: false, null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "ar_name"
  end

  create_table "jobs", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.text     "qualifications"
    t.text     "requirements"
    t.date     "start_date"
    t.date     "end_date"
    t.float    "experience_from"
    t.float    "experience_to"
    t.integer  "views_count"
    t.integer  "notification_type"
    t.string   "url"
    t.boolean  "license_required"
    t.boolean  "active"
    t.boolean  "deleted"
    t.integer  "user_id"
    t.integer  "company_id"
    t.integer  "job_type_id"
    t.integer  "job_status_id"
    t.integer  "job_category_id"
    t.integer  "functional_area_id"
    t.integer  "sector_id"
    t.integer  "job_education_id"
    t.integer  "job_experience_level_id"
    t.integer  "country_id"
    t.integer  "city_id"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.boolean  "is_featured",               default: false
    t.integer  "gender"
    t.string   "marital_status"
    t.date     "join_date"
    t.integer  "visa_status_id"
    t.integer  "age_group_id"
    t.integer  "salary_range_id"
    t.boolean  "notified",                  default: false
    t.boolean  "is_goolge_published",       default: false
    t.integer  "branch_id"
    t.boolean  "is_internal_hiring",        default: false
    t.integer  "department_id"
    t.integer  "latest_changor_user_id"
    t.boolean  "country_required"
    t.boolean  "city_required"
    t.boolean  "nationality_required"
    t.boolean  "gender_required"
    t.boolean  "age_required"
    t.boolean  "years_of_exp_required"
    t.boolean  "experience_level_required"
    t.boolean  "language_required"
    t.integer  "organization_id"
    t.string   "requisition_status"
    t.integer  "position_id"
    t.string   "employment_type"
    t.datetime "approved_at"
  end

  add_index "jobs", ["age_group_id"], name: "index_jobs_on_age_group_id", using: :btree
  add_index "jobs", ["branch_id"], name: "index_jobs_on_branch_id", using: :btree
  add_index "jobs", ["department_id"], name: "index_jobs_on_department_id", using: :btree
  add_index "jobs", ["organization_id"], name: "index_jobs_on_organization_id", using: :btree
  add_index "jobs", ["position_id"], name: "index_jobs_on_position_id", using: :btree
  add_index "jobs", ["salary_range_id"], name: "index_jobs_on_salary_range_id", using: :btree
  add_index "jobs", ["visa_status_id"], name: "index_jobs_on_visa_status_id", using: :btree

  create_table "jobseeker_certificates", force: :cascade do |t|
    t.string   "name"
    t.string   "institute"
    t.string   "attachment"
    t.string   "grade"
    t.integer  "jobseeker_id"
    t.date     "from"
    t.date     "to"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
    t.integer  "certificate_id"
    t.string   "document_s3_path"
  end

  add_index "jobseeker_certificates", ["certificate_id"], name: "index_jobseeker_certificates_on_certificate_id", using: :btree
  add_index "jobseeker_certificates", ["jobseeker_id"], name: "index_jobseeker_certificates_on_jobseeker_id", using: :btree

  create_table "jobseeker_company_broadcasts", force: :cascade do |t|
    t.integer  "jobseeker_id"
    t.integer  "company_id"
    t.string   "status"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "jobseeker_company_broadcasts", ["company_id"], name: "index_jobseeker_company_broadcasts_on_company_id", using: :btree
  add_index "jobseeker_company_broadcasts", ["jobseeker_id"], name: "index_jobseeker_company_broadcasts_on_jobseeker_id", using: :btree

  create_table "jobseeker_coverletters", force: :cascade do |t|
    t.integer  "jobseeker_id"
    t.string   "title"
    t.string   "file_path"
    t.string   "description"
    t.boolean  "default"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
    t.boolean  "is_deleted"
    t.string   "document_s3_path"
  end

  add_index "jobseeker_coverletters", ["jobseeker_id"], name: "index_jobseeker_coverletters_on_jobseeker_id", using: :btree

  create_table "jobseeker_educations", force: :cascade do |t|
    t.integer  "jobseeker_id"
    t.integer  "job_education_id"
    t.integer  "country_id"
    t.integer  "city_id"
    t.string   "grade"
    t.string   "school"
    t.string   "field_of_study"
    t.date     "from"
    t.date     "to"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
    t.string   "attachment"
    t.string   "document_s3_path"
    t.string   "degree_type"
    t.integer  "university_id"
    t.integer  "max_grade"
  end

  add_index "jobseeker_educations", ["job_education_id"], name: "index_jobseeker_educations_on_job_education_id", using: :btree
  add_index "jobseeker_educations", ["jobseeker_id"], name: "index_jobseeker_educations_on_jobseeker_id", using: :btree
  add_index "jobseeker_educations", ["university_id"], name: "index_jobseeker_educations_on_university_id", using: :btree

  create_table "jobseeker_experiences", force: :cascade do |t|
    t.integer  "jobseeker_id"
    t.integer  "sector_id"
    t.integer  "country_id"
    t.integer  "city_id"
    t.string   "position"
    t.string   "company_name"
    t.string   "department"
    t.text     "description"
    t.date     "from"
    t.date     "to"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
    t.integer  "company_id"
    t.string   "attachment"
    t.string   "document_s3_path"
  end

  add_index "jobseeker_experiences", ["company_id"], name: "index_jobseeker_experiences_on_company_id", using: :btree
  add_index "jobseeker_experiences", ["jobseeker_id"], name: "index_jobseeker_experiences_on_jobseeker_id", using: :btree
  add_index "jobseeker_experiences", ["sector_id"], name: "index_jobseeker_experiences_on_sector_id", using: :btree

  create_table "jobseeker_folders", force: :cascade do |t|
    t.integer  "jobseeker_id"
    t.integer  "folder_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "jobseeker_folders", ["folder_id"], name: "index_jobseeker_folders_on_folder_id", using: :btree
  add_index "jobseeker_folders", ["jobseeker_id"], name: "index_jobseeker_folders_on_jobseeker_id", using: :btree

  create_table "jobseeker_graduate_programs", force: :cascade do |t|
    t.decimal  "ielts_score"
    t.string   "ielts_document_file_name"
    t.string   "ielts_document_content_type"
    t.integer  "ielts_document_file_size"
    t.datetime "ielts_document_updated_at"
    t.decimal  "toefl_score"
    t.string   "toefl_document_file_name"
    t.string   "toefl_document_content_type"
    t.integer  "toefl_document_file_size"
    t.datetime "toefl_document_updated_at"
    t.decimal  "age"
    t.decimal  "bachelor_gpa"
    t.decimal  "master_gpa"
    t.integer  "nationality_id"
    t.integer  "jobseeker_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.datetime "rejection_sent_at"
  end

  add_index "jobseeker_graduate_programs", ["jobseeker_id"], name: "index_jobseeker_graduate_programs_on_jobseeker_id", using: :btree

  create_table "jobseeker_hash_tags", force: :cascade do |t|
    t.integer  "jobseeker_id"
    t.integer  "hash_tag_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "jobseeker_hash_tags", ["hash_tag_id"], name: "index_jobseeker_hash_tags_on_hash_tag_id", using: :btree
  add_index "jobseeker_hash_tags", ["jobseeker_id"], name: "index_jobseeker_hash_tags_on_jobseeker_id", using: :btree

  create_table "jobseeker_languages", force: :cascade do |t|
    t.integer  "jobseeker_id"
    t.integer  "language_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "jobseeker_languages", ["jobseeker_id"], name: "index_jobseeker_languages_on_jobseeker_id", using: :btree
  add_index "jobseeker_languages", ["language_id"], name: "index_jobseeker_languages_on_language_id", using: :btree

  create_table "jobseeker_on_board_documents", force: :cascade do |t|
    t.integer  "jobseeker_id"
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
    t.string   "type_of_document"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "jobseeker_on_board_documents", ["jobseeker_id"], name: "index_jobseeker_on_board_documents_on_jobseeker_id", using: :btree

  create_table "jobseeker_package_broadcasts", force: :cascade do |t|
    t.integer  "jobseeker_id"
    t.integer  "package_broadcast_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "num_credits"
    t.float    "price"
  end

  add_index "jobseeker_package_broadcasts", ["jobseeker_id"], name: "index_jobseeker_package_broadcasts_on_jobseeker_id", using: :btree
  add_index "jobseeker_package_broadcasts", ["package_broadcast_id"], name: "index_jobseeker_package_broadcasts_on_package_broadcast_id", using: :btree

  create_table "jobseeker_profile_views", force: :cascade do |t|
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "company_user_id"
    t.integer  "jobseeker_id"
    t.integer  "company_id"
  end

  add_index "jobseeker_profile_views", ["company_id"], name: "index_jobseeker_profile_views_on_company_id", using: :btree
  add_index "jobseeker_profile_views", ["company_user_id"], name: "index_jobseeker_profile_views_on_company_user_id", using: :btree
  add_index "jobseeker_profile_views", ["jobseeker_id"], name: "index_jobseeker_profile_views_on_jobseeker_id", using: :btree

  create_table "jobseeker_required_documents", force: :cascade do |t|
    t.string   "document_type"
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
    t.integer  "job_application_status_change_id"
    t.string   "status"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.text     "employer_comment"
  end

  add_index "jobseeker_required_documents", ["job_application_status_change_id"], name: "index_jobseeker_required_doc_on_job_app_status_change_id", using: :btree

  create_table "jobseeker_resumes", force: :cascade do |t|
    t.integer  "jobseeker_id"
    t.string   "title"
    t.string   "file_path"
    t.boolean  "default"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
    t.boolean  "is_deleted"
    t.string   "document_s3_path"
    t.text     "resume_data"
  end

  add_index "jobseeker_resumes", ["jobseeker_id"], name: "index_jobseeker_resumes_on_jobseeker_id", using: :btree

  create_table "jobseeker_skills", force: :cascade do |t|
    t.integer  "jobseeker_id"
    t.integer  "skill_id"
    t.integer  "level"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "jobseeker_skills", ["jobseeker_id"], name: "index_jobseeker_skills_on_jobseeker_id", using: :btree
  add_index "jobseeker_skills", ["skill_id"], name: "index_jobseeker_skills_on_skill_id", using: :btree

  create_table "jobseeker_tags", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "jobseeker_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "jobseeker_tags", ["jobseeker_id"], name: "index_jobseeker_tags_on_jobseeker_id", using: :btree
  add_index "jobseeker_tags", ["tag_id"], name: "index_jobseeker_tags_on_tag_id", using: :btree

  create_table "jobseekers", force: :cascade do |t|
    t.text     "focus"
    t.text     "summary"
    t.string   "mobile_phone"
    t.string   "home_phone"
    t.float    "current_salary"
    t.float    "expected_salary"
    t.float    "years_of_experience"
    t.string   "marital_status"
    t.string   "profile_video"
    t.string   "profile_video_image"
    t.string   "website"
    t.string   "zip"
    t.string   "address_line1"
    t.string   "address_line2"
    t.string   "google_plus_page_url"
    t.string   "linkedin_page_url"
    t.string   "facebook_page_url"
    t.string   "skype_id"
    t.integer  "user_id"
    t.integer  "job_type_id"
    t.integer  "job_category_id"
    t.integer  "functional_area_id"
    t.integer  "job_experience_level_id"
    t.integer  "sector_id"
    t.integer  "country_id"
    t.integer  "current_city_id"
    t.integer  "current_country_id"
    t.integer  "nationality_id"
    t.integer  "job_education_id"
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.string   "twitter_page_url"
    t.integer  "driving_license_country_id"
    t.integer  "notice_period_in_month",               default: 1
    t.integer  "visa_status_id"
    t.boolean  "visible_by_employer"
    t.integer  "complete_step"
    t.datetime "completed_at"
    t.string   "preferred_position"
    t.integer  "experience_range_id"
    t.integer  "current_salary_range_id"
    t.integer  "expected_salary_range_id"
    t.integer  "num_dependencies",                     default: 0
    t.string   "visa_code"
    t.string   "jobseeker_type",                       default: "normal"
    t.string   "document_nationality_id_file_name"
    t.string   "document_nationality_id_content_type"
    t.integer  "document_nationality_id_file_size"
    t.datetime "document_nationality_id_updated_at"
    t.string   "nationality_id_number"
    t.string   "id_number"
    t.string   "employment_type"
    t.string   "candidate_type"
    t.string   "religion"
    t.string   "grandfather_name"
    t.date     "effective_start_date"
    t.integer  "oracle_id"
    t.datetime "terminated_at"
  end

  add_index "jobseekers", ["country_id"], name: "index_jobseekers_on_country_id", using: :btree
  add_index "jobseekers", ["experience_range_id"], name: "index_jobseekers_on_experience_range_id", using: :btree
  add_index "jobseekers", ["functional_area_id"], name: "index_jobseekers_on_functional_area_id", using: :btree
  add_index "jobseekers", ["job_category_id"], name: "index_jobseekers_on_job_category_id", using: :btree
  add_index "jobseekers", ["job_education_id"], name: "index_jobseekers_on_job_education_id", using: :btree
  add_index "jobseekers", ["job_experience_level_id"], name: "index_jobseekers_on_job_experience_level_id", using: :btree
  add_index "jobseekers", ["job_type_id"], name: "index_jobseekers_on_job_type_id", using: :btree
  add_index "jobseekers", ["sector_id"], name: "index_jobseekers_on_sector_id", using: :btree
  add_index "jobseekers", ["user_id"], name: "index_jobseekers_on_user_id", using: :btree
  add_index "jobseekers", ["visa_status_id"], name: "index_jobseekers_on_visa_status_id", using: :btree

  create_table "languages", force: :cascade do |t|
    t.string   "name"
    t.boolean  "public"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "ar_name"
  end

  add_index "languages", ["name"], name: "index_languages_on_name", using: :btree

  create_table "likes", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "blog_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "likes", ["blog_id"], name: "index_likes_on_blog_id", using: :btree
  add_index "likes", ["user_id"], name: "index_likes_on_user_id", using: :btree

  create_table "medical_insurances", force: :cascade do |t|
    t.integer  "jobseeker_id"
    t.string   "english_name"
    t.string   "arabic_name"
    t.date     "birthday"
    t.string   "id_number"
    t.integer  "nationality_id"
    t.date     "start_date"
    t.date     "end_date"
    t.string   "relation"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "medical_insurances", ["jobseeker_id"], name: "index_medical_insurances_on_jobseeker_id", using: :btree

  create_table "new_sections", force: :cascade do |t|
    t.string   "name"
    t.string   "ar_name"
    t.integer  "department_id"
    t.integer  "unit_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "new_sections", ["department_id"], name: "index_new_sections_on_department_id", using: :btree
  add_index "new_sections", ["unit_id"], name: "index_new_sections_on_unit_id", using: :btree

  create_table "notes", force: :cascade do |t|
    t.integer  "job_application_id"
    t.string   "note"
    t.integer  "company_user_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "notes", ["company_user_id"], name: "index_notes_on_company_user_id", using: :btree
  add_index "notes", ["job_application_id"], name: "index_notes_on_job_application_id", using: :btree

  create_table "notifications", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "blog"
    t.integer  "poll_question"
    t.integer  "job"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.boolean  "newsletter",    default: true
    t.integer  "candidate"
  end

  add_index "notifications", ["user_id"], name: "index_notifications_on_user_id", using: :btree

  create_table "offer_analyses", force: :cascade do |t|
    t.integer  "job_application_id"
    t.decimal  "basic_salary"
    t.decimal  "housing_allowance"
    t.decimal  "transportation_allowance"
    t.decimal  "monthly_salary"
    t.decimal  "percentage_increase"
    t.integer  "level"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "user_id"
  end

  add_index "offer_analyses", ["job_application_id"], name: "index_offer_analyses_on_job_application_id", using: :btree
  add_index "offer_analyses", ["user_id"], name: "index_offer_analyses_on_user_id", using: :btree

  create_table "offer_approvers", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "level"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "position"
  end

  add_index "offer_approvers", ["user_id"], name: "index_offer_approvers_on_user_id", using: :btree

  create_table "offer_letter_requests", force: :cascade do |t|
    t.float    "basic_salary"
    t.float    "housing_salary"
    t.float    "transportation_salary"
    t.float    "mobile_allowance_salary"
    t.float    "total_salary"
    t.integer  "job_application_status_change_id"
    t.integer  "offer_letter_id"
    t.string   "offer_letter_type"
    t.string   "status_approval_one"
    t.string   "status_approval_two"
    t.string   "status_approval_three"
    t.string   "status_approval_four"
    t.string   "status_approval_five"
    t.datetime "date_approval_one"
    t.datetime "date_approval_two"
    t.datetime "date_approval_three"
    t.datetime "date_approval_four"
    t.datetime "date_approval_five"
    t.text     "comment_approval_one"
    t.text     "comment_approval_two"
    t.text     "comment_approval_three"
    t.text     "comment_approval_four"
    t.text     "comment_approval_five"
    t.text     "reply_jobseeker"
    t.string   "status_jobseeker"
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.date     "end_date"
    t.boolean  "deleted",                          default: false
    t.string   "title"
    t.float    "relocation_allowance"
    t.date     "start_date"
    t.string   "job_grade"
    t.date     "joining_date"
    t.integer  "hiring_manager_id"
  end

  add_index "offer_letter_requests", ["hiring_manager_id"], name: "index_offer_letter_requests_on_hiring_manager_id", using: :btree
  add_index "offer_letter_requests", ["job_application_status_change_id"], name: "index_offer_letter_requests_on_job_application_status_change_id", using: :btree
  add_index "offer_letter_requests", ["offer_letter_id"], name: "index_offer_letter_requests_on_offer_letter_id", using: :btree

  create_table "offer_letters", force: :cascade do |t|
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
    t.integer  "job_application_status_change_id"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.date     "joining_date"
    t.datetime "shared_to_stc_at"
    t.datetime "sent_to_candidate_at"
    t.datetime "received_from_stc_at"
    t.string   "jobseeker_status"
    t.date     "candidate_dob"
    t.string   "candidate_second_name"
    t.string   "candidate_third_name"
    t.string   "candidate_birth_city"
    t.string   "candidate_birth_country"
    t.string   "candidate_nationality"
    t.string   "candidate_religion"
    t.string   "candidate_gender"
  end

  add_index "offer_letters", ["job_application_status_change_id"], name: "index_offer_letters_on_job_application_status_change_id", using: :btree

  create_table "offer_requisitions", force: :cascade do |t|
    t.integer  "job_application_id"
    t.integer  "user_id"
    t.string   "status"
    t.string   "comment"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "salary_analysis_id"
    t.integer  "offer_analysis_id"
  end

  add_index "offer_requisitions", ["job_application_id"], name: "index_offer_requisitions_on_job_application_id", using: :btree
  add_index "offer_requisitions", ["offer_analysis_id"], name: "index_offer_requisitions_on_offer_analysis_id", using: :btree
  add_index "offer_requisitions", ["salary_analysis_id"], name: "index_offer_requisitions_on_salary_analysis_id", using: :btree
  add_index "offer_requisitions", ["user_id"], name: "index_offer_requisitions_on_user_id", using: :btree

  create_table "offices", force: :cascade do |t|
    t.integer  "company_id"
    t.string   "name"
    t.string   "ar_name"
    t.integer  "country_id"
    t.integer  "city_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "offices", ["city_id"], name: "index_offices_on_city_id", using: :btree
  add_index "offices", ["company_id"], name: "index_offices_on_company_id", using: :btree
  add_index "offices", ["country_id"], name: "index_offices_on_country_id", using: :btree

  create_table "organization_types", force: :cascade do |t|
    t.string   "name"
    t.string   "ar_name"
    t.integer  "order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "organization_users", force: :cascade do |t|
    t.integer  "organization_id"
    t.integer  "user_id"
    t.boolean  "is_manager",      default: true
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "organization_users", ["organization_id"], name: "index_organization_users_on_organization_id", using: :btree
  add_index "organization_users", ["user_id"], name: "index_organization_users_on_user_id", using: :btree

  create_table "organizations", force: :cascade do |t|
    t.string   "name"
    t.integer  "parent_organization_id"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "organization_type_id"
    t.integer  "oracle_id"
  end

  create_table "package_broadcasts", force: :cascade do |t|
    t.integer  "num_credits"
    t.float    "price"
    t.string   "currency"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "packages", force: :cascade do |t|
    t.string  "name"
    t.string  "description"
    t.float   "price"
    t.string  "currency"
    t.integer "job_postings"
    t.integer "db_access_days"
    t.boolean "employer_logo"
    t.boolean "branding"
    t.string  "details"
    t.string  "ar_name"
    t.string  "ar_description"
    t.text    "ar_details"
  end

  create_table "permissions", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "controller_name"
    t.string   "action"
    t.string   "name"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "permissions", ["user_id"], name: "index_permissions_on_user_id", using: :btree

  create_table "poll_answers", force: :cascade do |t|
    t.string   "answer"
    t.integer  "poll_question_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "poll_answers", ["poll_question_id"], name: "index_poll_answers_on_poll_question_id", using: :btree

  create_table "poll_questions", force: :cascade do |t|
    t.string   "question"
    t.string   "poll_type"
    t.boolean  "multiple_selection"
    t.boolean  "active"
    t.datetime "start_at"
    t.datetime "expire_at"
    t.integer  "user_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "poll_questions", ["user_id"], name: "index_poll_questions_on_user_id", using: :btree

  create_table "poll_results", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "poll_answer_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "poll_results", ["poll_answer_id"], name: "index_poll_results_on_poll_answer_id", using: :btree
  add_index "poll_results", ["user_id"], name: "index_poll_results_on_user_id", using: :btree

  create_table "position_cv_sources", force: :cascade do |t|
    t.string "name"
    t.string "ar_name"
  end

  create_table "position_statuses", force: :cascade do |t|
    t.string "name"
    t.string "ar_name"
  end

  create_table "positions", force: :cascade do |t|
    t.string   "job_title"
    t.string   "ar_job_title"
    t.string   "job_description"
    t.string   "employment_type"
    t.string   "military_level"
    t.string   "military_force"
    t.string   "position_grade"
    t.integer  "job_status_id"
    t.integer  "grade_id"
    t.integer  "job_experience_level_id"
    t.integer  "job_type_id"
    t.integer  "organization_id"
    t.integer  "position_status_id"
    t.integer  "position_cv_source_id"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.integer  "oracle_id"
    t.boolean  "is_deleted",              default: false
    t.string   "lock_code"
  end

  add_index "positions", ["grade_id"], name: "index_positions_on_grade_id", using: :btree
  add_index "positions", ["job_experience_level_id"], name: "index_positions_on_job_experience_level_id", using: :btree
  add_index "positions", ["job_status_id"], name: "index_positions_on_job_status_id", using: :btree
  add_index "positions", ["job_type_id"], name: "index_positions_on_job_type_id", using: :btree
  add_index "positions", ["organization_id"], name: "index_positions_on_organization_id", using: :btree
  add_index "positions", ["position_cv_source_id"], name: "index_positions_on_position_cv_source_id", using: :btree
  add_index "positions", ["position_status_id"], name: "index_positions_on_position_status_id", using: :btree

  create_table "ratings", force: :cascade do |t|
    t.integer  "creator_id"
    t.integer  "jobseeker_id"
    t.float    "rate",         default: 0.0
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "ratings", ["jobseeker_id"], name: "index_ratings_on_jobseeker_id", using: :btree

  create_table "requisitions", force: :cascade do |t|
    t.string   "status"
    t.integer  "user_id"
    t.integer  "job_id"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.text     "reason"
    t.boolean  "active",          default: false
    t.integer  "organization_id"
    t.datetime "approved_at"
    t.boolean  "is_deleted",      default: false
  end

  add_index "requisitions", ["job_id"], name: "index_requisitions_on_job_id", using: :btree
  add_index "requisitions", ["organization_id"], name: "index_requisitions_on_organization_id", using: :btree
  add_index "requisitions", ["user_id"], name: "index_requisitions_on_user_id", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.string   "ar_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "salary_analyses", force: :cascade do |t|
    t.integer  "job_application_id"
    t.decimal  "basic_salary"
    t.decimal  "housing_allowance"
    t.decimal  "transportation_allowance"
    t.decimal  "special_allowance"
    t.decimal  "ticket_allowance"
    t.decimal  "education_allowance"
    t.decimal  "incentives"
    t.decimal  "monthly_salary"
    t.integer  "level"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "salary_analyses", ["job_application_id"], name: "index_salary_analyses_on_job_application_id", using: :btree

  create_table "salary_ranges", force: :cascade do |t|
    t.integer  "salary_from"
    t.integer  "salary_to"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "saved_job_searches", force: :cascade do |t|
    t.integer  "jobseeker_id"
    t.integer  "alert_type_id"
    t.string   "title"
    t.string   "api_url"
    t.string   "web_url"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "saved_job_searches", ["alert_type_id"], name: "index_saved_job_searches_on_alert_type_id", using: :btree
  add_index "saved_job_searches", ["jobseeker_id"], name: "index_saved_job_searches_on_jobseeker_id", using: :btree

  create_table "saved_jobs", force: :cascade do |t|
    t.integer  "jobseeker_id"
    t.integer  "job_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "saved_jobs", ["job_id"], name: "index_saved_jobs_on_job_id", using: :btree
  add_index "saved_jobs", ["jobseeker_id"], name: "index_saved_jobs_on_jobseeker_id", using: :btree

  create_table "sections", force: :cascade do |t|
    t.string   "name"
    t.string   "ar_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sectors", force: :cascade do |t|
    t.string   "name",          default: "",    null: false
    t.integer  "display_order"
    t.boolean  "deleted",       default: false, null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "ar_name"
  end

  create_table "security_clearance_result_documents", force: :cascade do |t|
    t.integer  "job_application_id"
    t.string   "title"
    t.string   "file_path"
    t.boolean  "default"
    t.boolean  "is_deleted"
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "security_clearance_result_documents", ["job_application_id"], name: "index_security_clearance_result_documents_on_job_application_id", using: :btree

  create_table "skills", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "weight",           default: 0
    t.boolean  "is_auto_complete", default: false
  end

  create_table "states", force: :cascade do |t|
    t.string   "name"
    t.decimal  "latitude",   precision: 10, scale: 6
    t.decimal  "longitude",  precision: 10, scale: 6
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "country_id"
  end

  add_index "states", ["country_id"], name: "index_states_on_country_id", using: :btree
  add_index "states", ["name"], name: "index_states_on_name", using: :btree

  create_table "suggested_candidates", force: :cascade do |t|
    t.integer  "job_id"
    t.integer  "jobseeker_id"
    t.float    "matching_percentage"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "suggested_candidates", ["job_id"], name: "index_suggested_candidates_on_job_id", using: :btree
  add_index "suggested_candidates", ["jobseeker_id"], name: "index_suggested_candidates_on_jobseeker_id", using: :btree

  create_table "tag_types", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tags", force: :cascade do |t|
    t.string   "name"
    t.integer  "tag_type_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "weight",      default: 0
  end

  add_index "tags", ["tag_type_id"], name: "index_tags_on_tag_type_id", using: :btree

  create_table "tmp_cities", force: :cascade do |t|
    t.string   "name"
    t.integer  "country_id"
    t.string   "country_name"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "units", force: :cascade do |t|
    t.string   "name"
    t.string   "ar_name"
    t.integer  "department_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "units", ["department_id"], name: "index_units_on_department_id", using: :btree

  create_table "universities", force: :cascade do |t|
    t.string   "name"
    t.integer  "country_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "universities", ["country_id"], name: "index_universities_on_country_id", using: :btree

  create_table "user_invitations", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "gmail_contacts",   default: [],              array: true
    t.string   "yahoo_contacts",   default: [],              array: true
    t.string   "outlook_contacts", default: [],              array: true
    t.string   "twitter_contacts", default: [],              array: true
  end

  add_index "user_invitations", ["user_id"], name: "index_user_invitations_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                             default: "",    null: false
    t.string   "encrypted_password",                default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                     default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "auth_token",                        default: ""
    t.integer  "gender"
    t.date     "birthday"
    t.string   "profile_image"
    t.integer  "country_id"
    t.integer  "state_id"
    t.integer  "city_id"
    t.boolean  "active"
    t.boolean  "deleted"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "video_file_name"
    t.string   "video_content_type"
    t.integer  "video_file_size"
    t.datetime "video_updated_at"
    t.string   "video_screenshot_file_name"
    t.string   "video_screenshot_content_type"
    t.integer  "video_screenshot_file_size"
    t.datetime "video_screenshot_updated_at"
    t.datetime "last_active"
    t.string   "avatar_s3_path"
    t.string   "video_s3_path"
    t.string   "position"
    t.integer  "section_id"
    t.integer  "department_id"
    t.integer  "office_id"
    t.integer  "unit_id"
    t.integer  "grade_id"
    t.boolean  "is_recruiter",                      default: false
    t.boolean  "is_interviewer",                    default: false
    t.string   "ext_employer_id"
    t.date     "start_date"
    t.date     "end_date"
    t.string   "middle_name"
    t.string   "document_e_signature_file_name"
    t.string   "document_e_signature_content_type"
    t.integer  "document_e_signature_file_size"
    t.datetime "document_e_signature_updated_at"
    t.integer  "new_section_id"
    t.boolean  "is_hiring_manager"
    t.integer  "role_id"
    t.boolean  "assigned_to_organization_level",    default: false
    t.boolean  "is_last_approver",                  default: false
    t.boolean  "is_approver",                       default: true
    t.integer  "oracle_id"
  end

  add_index "users", ["auth_token"], name: "index_users_on_auth_token", unique: true, using: :btree
  add_index "users", ["city_id"], name: "index_users_on_city_id", using: :btree
  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["country_id"], name: "index_users_on_country_id", using: :btree
  add_index "users", ["department_id"], name: "index_users_on_department_id", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["grade_id"], name: "index_users_on_grade_id", using: :btree
  add_index "users", ["new_section_id"], name: "index_users_on_new_section_id", using: :btree
  add_index "users", ["office_id"], name: "index_users_on_office_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["section_id"], name: "index_users_on_section_id", using: :btree
  add_index "users", ["state_id"], name: "index_users_on_state_id", using: :btree
  add_index "users", ["unit_id"], name: "index_users_on_unit_id", using: :btree

  create_table "visa_statuses", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "ar_name"
  end

  add_foreign_key "assigned_folders", "folders"
  add_foreign_key "assigned_folders", "users"
  add_foreign_key "bank_accounts", "jobseekers"
  add_foreign_key "blog_tags", "blogs"
  add_foreign_key "blog_tags", "tags"
  add_foreign_key "blogs", "company_users"
  add_foreign_key "boarding_forms", "job_applications"
  add_foreign_key "boarding_requisitions", "boarding_forms"
  add_foreign_key "boarding_requisitions", "job_applications"
  add_foreign_key "boarding_requisitions", "users"
  add_foreign_key "branches", "companies"
  add_foreign_key "budgeted_vacancies", "departments"
  add_foreign_key "budgeted_vacancies", "grades"
  add_foreign_key "budgeted_vacancies", "job_experience_levels"
  add_foreign_key "budgeted_vacancies", "job_types"
  add_foreign_key "budgeted_vacancies", "new_sections"
  add_foreign_key "budgeted_vacancies", "sections"
  add_foreign_key "budgeted_vacancies", "units"
  add_foreign_key "calls", "interviews"
  add_foreign_key "calls", "users"
  add_foreign_key "candidate_information_documents", "job_application_status_changes"
  add_foreign_key "candidate_information_documents", "users"
  add_foreign_key "career_fair_applications", "career_fairs"
  add_foreign_key "career_fair_applications", "jobseekers"
  add_foreign_key "career_fairs", "cities"
  add_foreign_key "career_fairs", "countries"
  add_foreign_key "cities", "countries"
  add_foreign_key "cities", "states"
  add_foreign_key "comments", "blogs"
  add_foreign_key "comments", "users"
  add_foreign_key "companies", "cities"
  add_foreign_key "companies", "company_classifications"
  add_foreign_key "companies", "company_sizes"
  add_foreign_key "companies", "company_types"
  add_foreign_key "companies", "countries"
  add_foreign_key "companies", "sectors"
  add_foreign_key "company_countries", "companies"
  add_foreign_key "company_countries", "countries"
  add_foreign_key "company_followers", "companies"
  add_foreign_key "company_followers", "jobseekers"
  add_foreign_key "company_members", "companies"
  add_foreign_key "company_users", "companies"
  add_foreign_key "company_users", "users"
  add_foreign_key "country_geo_groups", "countries"
  add_foreign_key "country_geo_groups", "geo_groups"
  add_foreign_key "cultures", "companies"
  add_foreign_key "employer_notifications", "email_templates"
  add_foreign_key "employer_notifications", "users"
  add_foreign_key "evaluation_answers", "evaluation_questions"
  add_foreign_key "evaluation_answers", "evaluation_submits"
  add_foreign_key "evaluation_questions", "evaluation_forms"
  add_foreign_key "evaluation_submit_requisitions", "evaluation_forms"
  add_foreign_key "evaluation_submit_requisitions", "evaluation_submits"
  add_foreign_key "evaluation_submit_requisitions", "job_applications"
  add_foreign_key "evaluation_submit_requisitions", "organizations"
  add_foreign_key "evaluation_submit_requisitions", "users"
  add_foreign_key "evaluation_submits", "evaluation_forms"
  add_foreign_key "evaluation_submits", "job_applications"
  add_foreign_key "evaluation_submits", "users"
  add_foreign_key "featured_companies", "companies"
  add_foreign_key "folders", "folders", column: "parent_id"
  add_foreign_key "folders", "users", column: "creator_id"
  add_foreign_key "grades", "companies"
  add_foreign_key "hiring_manager_owners", "hiring_managers"
  add_foreign_key "hiring_manager_owners", "users"
  add_foreign_key "hiring_managers", "departments"
  add_foreign_key "hiring_managers", "grades"
  add_foreign_key "hiring_managers", "new_sections"
  add_foreign_key "hiring_managers", "offices"
  add_foreign_key "hiring_managers", "sections"
  add_foreign_key "hiring_managers", "units"
  add_foreign_key "hiring_managers", "users", column: "approver_five_id"
  add_foreign_key "hiring_managers", "users", column: "approver_four_id"
  add_foreign_key "hiring_managers", "users", column: "approver_one_id"
  add_foreign_key "hiring_managers", "users", column: "approver_three_id"
  add_foreign_key "hiring_managers", "users", column: "approver_two_id"
  add_foreign_key "identities", "users"
  add_foreign_key "interview_committee_members", "interviews"
  add_foreign_key "interview_committee_members", "users"
  add_foreign_key "interviews", "job_application_status_changes"
  add_foreign_key "interviews", "users", column: "interviewer_id"
  add_foreign_key "invited_jobseekers", "jobs"
  add_foreign_key "invited_jobseekers", "jobseekers"
  add_foreign_key "job_application_logs", "job_applications"
  add_foreign_key "job_application_logs", "users"
  add_foreign_key "job_application_status_changes", "job_application_statuses"
  add_foreign_key "job_application_status_changes", "job_applications"
  add_foreign_key "job_application_status_changes", "users", column: "employer_id"
  add_foreign_key "job_application_status_changes", "users", column: "jobseeker_id"
  add_foreign_key "job_applications", "job_application_statuses"
  add_foreign_key "job_applications", "jobs"
  add_foreign_key "job_applications", "jobseeker_coverletters"
  add_foreign_key "job_applications", "jobseeker_resumes"
  add_foreign_key "job_applications", "jobseekers"
  add_foreign_key "job_applications", "users"
  add_foreign_key "job_benefits", "benefits"
  add_foreign_key "job_benefits", "jobs"
  add_foreign_key "job_certificates", "certificates"
  add_foreign_key "job_certificates", "jobs"
  add_foreign_key "job_countries", "countries"
  add_foreign_key "job_countries", "jobs"
  add_foreign_key "job_geo_groups", "geo_groups"
  add_foreign_key "job_geo_groups", "jobs"
  add_foreign_key "job_history", "jobs"
  add_foreign_key "job_history", "users"
  add_foreign_key "job_languages", "jobs"
  add_foreign_key "job_languages", "languages"
  add_foreign_key "job_requests", "budgeted_vacancies"
  add_foreign_key "job_requests", "grades"
  add_foreign_key "job_requests", "hiring_managers"
  add_foreign_key "job_requests", "jobs"
  add_foreign_key "job_requests", "organizations"
  add_foreign_key "job_skills", "jobs"
  add_foreign_key "job_skills", "skills"
  add_foreign_key "job_tags", "jobs"
  add_foreign_key "job_tags", "tags"
  add_foreign_key "jobs", "age_groups"
  add_foreign_key "jobs", "branches"
  add_foreign_key "jobs", "cities"
  add_foreign_key "jobs", "companies"
  add_foreign_key "jobs", "countries"
  add_foreign_key "jobs", "departments"
  add_foreign_key "jobs", "functional_areas"
  add_foreign_key "jobs", "job_categories"
  add_foreign_key "jobs", "job_educations"
  add_foreign_key "jobs", "job_experience_levels"
  add_foreign_key "jobs", "job_statuses"
  add_foreign_key "jobs", "job_types"
  add_foreign_key "jobs", "organizations"
  add_foreign_key "jobs", "positions"
  add_foreign_key "jobs", "salary_ranges"
  add_foreign_key "jobs", "users"
  add_foreign_key "jobs", "users", column: "latest_changor_user_id"
  add_foreign_key "jobs", "visa_statuses"
  add_foreign_key "jobseeker_certificates", "certificates"
  add_foreign_key "jobseeker_certificates", "jobseekers"
  add_foreign_key "jobseeker_company_broadcasts", "companies"
  add_foreign_key "jobseeker_company_broadcasts", "jobseekers"
  add_foreign_key "jobseeker_coverletters", "jobseekers"
  add_foreign_key "jobseeker_educations", "job_educations"
  add_foreign_key "jobseeker_educations", "jobseekers"
  add_foreign_key "jobseeker_educations", "universities"
  add_foreign_key "jobseeker_experiences", "companies"
  add_foreign_key "jobseeker_experiences", "jobseekers"
  add_foreign_key "jobseeker_experiences", "sectors"
  add_foreign_key "jobseeker_folders", "folders"
  add_foreign_key "jobseeker_folders", "jobseekers"
  add_foreign_key "jobseeker_graduate_programs", "jobseekers"
  add_foreign_key "jobseeker_hash_tags", "hash_tags"
  add_foreign_key "jobseeker_hash_tags", "jobseekers"
  add_foreign_key "jobseeker_languages", "jobseekers"
  add_foreign_key "jobseeker_languages", "languages"
  add_foreign_key "jobseeker_on_board_documents", "jobseekers"
  add_foreign_key "jobseeker_package_broadcasts", "jobseekers"
  add_foreign_key "jobseeker_package_broadcasts", "package_broadcasts"
  add_foreign_key "jobseeker_profile_views", "companies"
  add_foreign_key "jobseeker_profile_views", "company_users"
  add_foreign_key "jobseeker_profile_views", "jobseekers"
  add_foreign_key "jobseeker_required_documents", "job_application_status_changes"
  add_foreign_key "jobseeker_resumes", "jobseekers"
  add_foreign_key "jobseeker_skills", "jobseekers"
  add_foreign_key "jobseeker_skills", "skills"
  add_foreign_key "jobseeker_tags", "jobseekers"
  add_foreign_key "jobseeker_tags", "tags"
  add_foreign_key "jobseekers", "experience_ranges"
  add_foreign_key "jobseekers", "functional_areas"
  add_foreign_key "jobseekers", "job_categories"
  add_foreign_key "jobseekers", "job_educations"
  add_foreign_key "jobseekers", "job_experience_levels"
  add_foreign_key "jobseekers", "job_types"
  add_foreign_key "jobseekers", "salary_ranges", column: "current_salary_range_id"
  add_foreign_key "jobseekers", "salary_ranges", column: "expected_salary_range_id"
  add_foreign_key "jobseekers", "sectors"
  add_foreign_key "jobseekers", "users"
  add_foreign_key "jobseekers", "visa_statuses"
  add_foreign_key "likes", "blogs"
  add_foreign_key "likes", "users"
  add_foreign_key "medical_insurances", "countries", column: "nationality_id"
  add_foreign_key "medical_insurances", "jobseekers"
  add_foreign_key "new_sections", "departments"
  add_foreign_key "new_sections", "units"
  add_foreign_key "notes", "company_users"
  add_foreign_key "notes", "job_applications"
  add_foreign_key "notifications", "users"
  add_foreign_key "offer_analyses", "job_applications"
  add_foreign_key "offer_analyses", "users"
  add_foreign_key "offer_approvers", "users"
  add_foreign_key "offer_letter_requests", "hiring_managers"
  add_foreign_key "offer_letter_requests", "job_application_status_changes"
  add_foreign_key "offer_letter_requests", "offer_letters"
  add_foreign_key "offer_letters", "job_application_status_changes"
  add_foreign_key "offer_requisitions", "job_applications"
  add_foreign_key "offer_requisitions", "offer_analyses"
  add_foreign_key "offer_requisitions", "salary_analyses"
  add_foreign_key "offer_requisitions", "users"
  add_foreign_key "offices", "cities"
  add_foreign_key "offices", "companies"
  add_foreign_key "offices", "countries"
  add_foreign_key "organization_users", "organizations"
  add_foreign_key "organization_users", "users"
  add_foreign_key "organizations", "organizations", column: "parent_organization_id"
  add_foreign_key "permissions", "users"
  add_foreign_key "poll_answers", "poll_questions"
  add_foreign_key "poll_questions", "users"
  add_foreign_key "poll_results", "poll_answers"
  add_foreign_key "poll_results", "users"
  add_foreign_key "ratings", "jobseekers"
  add_foreign_key "ratings", "users", column: "creator_id"
  add_foreign_key "requisitions", "jobs"
  add_foreign_key "requisitions", "organizations"
  add_foreign_key "requisitions", "users"
  add_foreign_key "salary_analyses", "job_applications"
  add_foreign_key "saved_job_searches", "alert_types"
  add_foreign_key "saved_job_searches", "jobseekers"
  add_foreign_key "saved_jobs", "jobs"
  add_foreign_key "saved_jobs", "jobseekers"
  add_foreign_key "states", "countries"
  add_foreign_key "suggested_candidates", "jobs"
  add_foreign_key "suggested_candidates", "jobseekers"
  add_foreign_key "tags", "tag_types"
  add_foreign_key "units", "departments"
  add_foreign_key "universities", "countries"
  add_foreign_key "user_invitations", "users"
  add_foreign_key "users", "departments"
  add_foreign_key "users", "grades"
  add_foreign_key "users", "new_sections"
  add_foreign_key "users", "offices"
  add_foreign_key "users", "sections"
  add_foreign_key "users", "units"
end
