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

ActiveRecord::Schema.define(version: 2019_12_10_101308) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "bookings_bookings", force: :cascade do |t|
    t.date "date", null: false
    t.integer "bookings_subject_id", null: false
    t.integer "bookings_placement_request_id", null: false
    t.integer "bookings_school_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "placement_details"
    t.string "contact_name"
    t.string "contact_number"
    t.string "contact_email"
    t.text "location"
    t.string "candidate_instructions"
    t.integer "duration", default: 1, null: false
    t.datetime "accepted_at"
    t.boolean "attended"
    t.index ["bookings_placement_request_id"], name: "index_bookings_bookings_on_bookings_placement_request_id", unique: true
    t.index ["bookings_school_id"], name: "index_bookings_bookings_on_bookings_school_id"
    t.index ["bookings_subject_id"], name: "index_bookings_bookings_on_bookings_subject_id"
  end

  create_table "bookings_candidates", force: :cascade do |t|
    t.uuid "gitis_uuid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "confirmed_at"
    t.boolean "created_in_gitis", default: false
    t.index ["gitis_uuid"], name: "index_bookings_candidates_on_gitis_uuid", unique: true
  end

  create_table "bookings_phases", force: :cascade do |t|
    t.string "name", limit: 32, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position"
    t.integer "edubase_id"
    t.boolean "supports_subjects", default: true, null: false
    t.index ["name"], name: "index_bookings_phases_on_name", unique: true
    t.index ["position"], name: "index_bookings_phases_on_position", unique: true
  end

  create_table "bookings_placement_date_subjects", force: :cascade do |t|
    t.bigint "bookings_placement_date_id"
    t.bigint "bookings_subject_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bookings_placement_date_id"], name: "index_placement_date_subject_on_date_id"
    t.index ["bookings_subject_id"], name: "index_placement_date_subject_on_subject_id"
  end

  create_table "bookings_placement_dates", force: :cascade do |t|
    t.date "date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "duration", default: 1, null: false
    t.boolean "active", default: true, null: false
    t.integer "bookings_school_id", null: false
    t.integer "max_bookings_count"
    t.datetime "published_at"
    t.boolean "subject_specific", default: false, null: false
    t.boolean "supports_subjects"
    t.index ["bookings_school_id"], name: "index_bookings_placement_dates_on_bookings_school_id"
  end

  create_table "bookings_placement_request_cancellations", force: :cascade do |t|
    t.bigint "bookings_placement_request_id"
    t.text "reason", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "cancelled_by", null: false
    t.datetime "sent_at"
    t.text "extra_details"
    t.datetime "viewed_at"
    t.string "rejection_category"
    t.index ["bookings_placement_request_id"], name: "index_cancellations_on_bookings_placement_request_id"
    t.index ["rejection_category"], name: "index_bookings_placement_request_cancellations_category"
  end

  create_table "bookings_placement_requests", force: :cascade do |t|
    t.text "objectives", null: false
    t.integer "urn", null: false
    t.string "degree_stage", null: false
    t.text "degree_stage_explaination"
    t.string "degree_subject", null: false
    t.string "teaching_stage", null: false
    t.string "subject_first_choice", null: false
    t.string "subject_second_choice", null: false
    t.boolean "has_dbs_check", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "availability"
    t.integer "bookings_placement_date_id"
    t.integer "bookings_school_id"
    t.string "token"
    t.uuid "analytics_tracking_uuid"
    t.datetime "viewed_at"
    t.bigint "candidate_id"
    t.bigint "bookings_subject_id"
    t.index ["bookings_placement_date_id"], name: "index_bookings_placement_requests_on_bookings_placement_date_id"
    t.index ["bookings_school_id"], name: "index_bookings_placement_requests_on_bookings_school_id"
    t.index ["bookings_subject_id"], name: "index_bookings_placement_requests_on_bookings_subject_id"
    t.index ["candidate_id"], name: "index_bookings_placement_requests_on_candidate_id"
    t.index ["token"], name: "index_bookings_placement_requests_on_token", unique: true
  end

  create_table "bookings_profiles", force: :cascade do |t|
    t.bigint "school_id"
    t.string "dbs_required"
    t.text "dbs_policy"
    t.text "individual_requirements"
    t.boolean "primary_phase", null: false
    t.boolean "secondary_phase", null: false
    t.boolean "college_phase", null: false
    t.boolean "key_stage_early_years", null: false
    t.boolean "key_stage_1", null: false
    t.boolean "key_stage_2", null: false
    t.text "description_details"
    t.boolean "dress_code_business", null: false
    t.boolean "dress_code_cover_tattoos", null: false
    t.boolean "dress_code_remove_piercings", null: false
    t.boolean "dress_code_smart_casual", null: false
    t.text "dress_code_other_details"
    t.boolean "parking_provided", null: false
    t.text "parking_details", null: false
    t.text "disabled_facilities"
    t.string "start_time", null: false
    t.string "end_time", null: false
    t.boolean "flexible_on_times", null: false
    t.text "experience_details"
    t.text "teacher_training_info"
    t.string "teacher_training_url"
    t.string "admin_contact_full_name", null: false
    t.string "admin_contact_email", null: false
    t.string "admin_contact_phone", null: false
    t.decimal "administration_fee_amount_pounds", precision: 6, scale: 2
    t.text "administration_fee_description"
    t.string "administration_fee_interval"
    t.text "administration_fee_payment_method"
    t.decimal "dbs_fee_amount_pounds", precision: 6, scale: 2
    t.text "dbs_fee_description"
    t.string "dbs_fee_interval"
    t.text "dbs_fee_payment_method"
    t.decimal "other_fee_amount_pounds", precision: 6, scale: 2
    t.text "other_fee_description"
    t.string "other_fee_interval"
    t.text "other_fee_payment_method"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "flexible_on_times_details"
    t.string "admin_contact_email_secondary"
    t.boolean "dbs_requires_check"
    t.text "dbs_policy_details"
    t.boolean "supports_access_needs"
    t.text "access_needs_description"
    t.boolean "disability_confident"
    t.boolean "has_access_needs_policy"
    t.string "access_needs_policy_url"
    t.index ["school_id"], name: "index_bookings_profiles_on_school_id", unique: true
  end

  create_table "bookings_school_searches", force: :cascade do |t|
    t.string "query", limit: 128
    t.string "location", limit: 128
    t.integer "radius", default: 10
    t.integer "subjects", array: true
    t.integer "phases", array: true
    t.integer "max_fee"
    t.integer "page"
    t.integer "number_of_results", default: 0
    t.geography "coordinates", limit: {:srid=>4326, :type=>"st_point", :geographic=>true}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "analytics_tracking_uuid"
  end

  create_table "bookings_school_types", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.integer "edubase_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_bookings_school_types_on_name", unique: true
  end

  create_table "bookings_schools", force: :cascade do |t|
    t.string "name", limit: 128, null: false
    t.geography "coordinates", limit: {:srid=>4326, :type=>"st_point", :geographic=>true}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "fee", default: 0, null: false
    t.integer "urn", null: false
    t.string "website"
    t.string "address_1", null: false
    t.string "address_2"
    t.string "address_3"
    t.string "town"
    t.string "county"
    t.string "postcode", null: false
    t.integer "bookings_school_type_id", null: false
    t.string "contact_email", limit: 64
    t.text "placement_info"
    t.boolean "teacher_training_provider", default: false, null: false
    t.text "teacher_training_info"
    t.text "primary_key_stage_info"
    t.text "availability_info"
    t.string "teacher_training_website"
    t.boolean "enabled", default: false, null: false
    t.boolean "availability_preference_fixed", default: false
    t.integer "views", default: 0, null: false
    t.uuid "dfe_signin_organisation_uuid"
    t.index ["coordinates"], name: "index_bookings_schools_on_coordinates", using: :gist
    t.index ["name"], name: "index_bookings_schools_on_name"
    t.index ["urn"], name: "index_bookings_schools_on_urn", unique: true
  end

  create_table "bookings_schools_phases", force: :cascade do |t|
    t.integer "bookings_school_id", null: false
    t.integer "bookings_phase_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bookings_schools_subjects", force: :cascade do |t|
    t.integer "bookings_school_id", null: false
    t.integer "bookings_subject_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bookings_school_id", "bookings_subject_id"], name: "index_bookings_schools_subjects_school_id_and_subject_id", unique: true
  end

  create_table "bookings_subjects", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "gitis_uuid"
    t.boolean "hidden", default: false
    t.boolean "secondary_subject", default: true, null: false
    t.index ["gitis_uuid"], name: "index_bookings_subjects_on_gitis_uuid", unique: true
    t.index ["hidden"], name: "index_bookings_subjects_on_hidden"
    t.index ["name"], name: "index_bookings_subjects_on_name", unique: true
  end

  create_table "candidates_session_tokens", force: :cascade do |t|
    t.string "token", null: false
    t.bigint "candidate_id", null: false
    t.datetime "expired_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "confirmed_at"
    t.index ["candidate_id"], name: "index_candidates_session_tokens_on_candidate_id"
    t.index ["token"], name: "index_candidates_session_tokens_on_token", unique: true
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "cron"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "events", force: :cascade do |t|
    t.integer "bookings_school_id"
    t.string "event_type", null: false
    t.integer "recordable_id"
    t.string "recordable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "bookings_candidate_id"
    t.index ["bookings_candidate_id"], name: "index_events_on_bookings_candidate_id"
    t.index ["bookings_school_id"], name: "index_events_on_bookings_school_id"
  end

  create_table "feedbacks", force: :cascade do |t|
    t.string "type", null: false
    t.integer "reason_for_using_service", null: false
    t.text "reason_for_using_service_explanation"
    t.integer "rating", null: false
    t.text "improvements"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "urn"
    t.boolean "successful_visit"
    t.text "unsuccessful_visit_explanation"
    t.string "referrer"
  end

  create_table "schools_on_boarding_profile_subjects", force: :cascade do |t|
    t.bigint "schools_school_profile_id"
    t.bigint "bookings_subject_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bookings_subject_id"], name: "index_profile_subjects_on_school_profile_i"
    t.index ["schools_school_profile_id"], name: "index_profile_subjects_on_school_profile_id"
  end

  create_table "schools_school_profiles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "candidate_requirement_dbs_requirement"
    t.text "candidate_requirement_dbs_policy"
    t.boolean "candidate_requirement_requirements"
    t.text "candidate_requirement_requirements_details"
    t.boolean "fees_administration_fees"
    t.boolean "fees_dbs_fees"
    t.boolean "fees_other_fees"
    t.decimal "administration_fee_amount_pounds", precision: 6, scale: 2
    t.text "administration_fee_description"
    t.string "administration_fee_interval"
    t.text "administration_fee_payment_method"
    t.decimal "dbs_fee_amount_pounds", precision: 6, scale: 2
    t.text "dbs_fee_description"
    t.string "dbs_fee_interval", default: "One-off"
    t.text "dbs_fee_payment_method"
    t.decimal "other_fee_amount_pounds", precision: 6, scale: 2
    t.text "other_fee_description"
    t.string "other_fee_interval"
    t.text "other_fee_payment_method"
    t.boolean "phases_list_primary", default: false, null: false
    t.boolean "phases_list_secondary", default: false, null: false
    t.boolean "phases_list_college", default: false, null: false
    t.boolean "key_stage_list_early_years", default: false
    t.boolean "key_stage_list_key_stage_1", default: false
    t.boolean "key_stage_list_key_stage_2", default: false
    t.text "description_details"
    t.boolean "candidate_experience_detail_business_dress", default: false
    t.boolean "candidate_experience_detail_cover_up_tattoos", default: false
    t.boolean "candidate_experience_detail_remove_piercings", default: false
    t.boolean "candidate_experience_detail_smart_casual", default: false
    t.boolean "candidate_experience_detail_other_dress_requirements", default: false
    t.string "candidate_experience_detail_other_dress_requirements_detail"
    t.boolean "candidate_experience_detail_parking_provided"
    t.string "candidate_experience_detail_parking_details"
    t.string "candidate_experience_detail_nearby_parking_details"
    t.boolean "candidate_experience_detail_disabled_facilities"
    t.string "candidate_experience_detail_disabled_facilities_details"
    t.string "candidate_experience_detail_start_time"
    t.string "candidate_experience_detail_end_time"
    t.boolean "candidate_experience_detail_times_flexible"
    t.text "experience_outline_candidate_experience"
    t.boolean "experience_outline_provides_teacher_training"
    t.text "experience_outline_teacher_training_details"
    t.string "experience_outline_teacher_training_url"
    t.string "admin_contact_full_name"
    t.string "admin_contact_email"
    t.string "admin_contact_phone"
    t.integer "bookings_school_id", null: false
    t.boolean "phases_list_secondary_and_college", default: false, null: false
    t.boolean "confirmation_acceptance", default: false
    t.text "candidate_experience_detail_times_flexible_details"
    t.string "admin_contact_email_secondary"
    t.boolean "administration_fee_step_completed", default: false
    t.boolean "dbs_fee_step_completed", default: false
    t.boolean "other_fee_step_completed", default: false
    t.boolean "dbs_requirement_requires_check"
    t.text "dbs_requirement_dbs_policy_details"
    t.text "dbs_requirement_no_dbs_policy_details"
    t.boolean "show_candidate_requirements_selection", default: false
    t.boolean "candidate_requirements_selection_on_teacher_training_course"
    t.boolean "candidate_requirements_selection_live_locally"
    t.integer "candidate_requirements_selection_maximum_distance_from_school"
    t.boolean "candidate_requirements_selection_other"
    t.text "candidate_requirements_selection_other_details"
    t.boolean "access_needs_support_supports_access_needs"
    t.boolean "candidate_requirements_choice_has_requirements"
    t.boolean "candidate_requirements_selection_step_completed", default: false
    t.boolean "candidate_requirements_selection_not_on_another_training_course"
    t.boolean "candidate_requirements_selection_has_or_working_towards_degree"
    t.string "access_needs_detail_description"
    t.boolean "disability_confident_is_disability_confident"
    t.boolean "access_needs_policy_has_access_needs_policy"
    t.string "access_needs_policy_url"
    t.boolean "candidate_requirements_selection_provide_photo_identification"
    t.text "candidate_requirements_selection_photo_identification_details"
    t.index ["bookings_school_id"], name: "index_schools_school_profiles_on_bookings_school_id"
  end

  add_foreign_key "bookings_bookings", "bookings_placement_requests"
  add_foreign_key "bookings_bookings", "bookings_schools"
  add_foreign_key "bookings_bookings", "bookings_subjects"
  add_foreign_key "bookings_placement_date_subjects", "bookings_placement_dates"
  add_foreign_key "bookings_placement_date_subjects", "bookings_subjects"
  add_foreign_key "bookings_placement_dates", "bookings_schools"
  add_foreign_key "bookings_placement_request_cancellations", "bookings_placement_requests"
  add_foreign_key "bookings_placement_requests", "bookings_candidates", column: "candidate_id"
  add_foreign_key "bookings_placement_requests", "bookings_placement_dates"
  add_foreign_key "bookings_placement_requests", "bookings_schools"
  add_foreign_key "bookings_placement_requests", "bookings_subjects"
  add_foreign_key "bookings_profiles", "bookings_schools", column: "school_id"
  add_foreign_key "bookings_schools", "bookings_school_types"
  add_foreign_key "bookings_schools_phases", "bookings_phases"
  add_foreign_key "bookings_schools_phases", "bookings_schools"
  add_foreign_key "bookings_schools_subjects", "bookings_schools"
  add_foreign_key "bookings_schools_subjects", "bookings_subjects"
  add_foreign_key "candidates_session_tokens", "bookings_candidates", column: "candidate_id"
  add_foreign_key "events", "bookings_candidates"
  add_foreign_key "events", "bookings_schools"
  add_foreign_key "schools_school_profiles", "bookings_schools"
end
