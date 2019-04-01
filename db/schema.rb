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

ActiveRecord::Schema.define(version: 2019_04_03_151747) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "bookings_phases", force: :cascade do |t|
    t.string "name", limit: 32, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position"
    t.integer "edubase_id"
    t.index ["name"], name: "index_bookings_phases_on_name"
    t.index ["position"], name: "index_bookings_phases_on_position", unique: true
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
    t.text "availability", null: false
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
    t.index ["name"], name: "index_bookings_subjects_on_name", unique: true
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
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "schools_on_boarding_phase_subjects", force: :cascade do |t|
    t.bigint "schools_school_profile_id"
    t.bigint "bookings_phase_id"
    t.bigint "bookings_subject_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bookings_phase_id"], name: "index_schools_on_boarding_phase_subjects_on_bookings_phase_id"
    t.index ["bookings_subject_id"], name: "index_schools_on_boarding_phase_subjects_on_bookings_subject_id"
    t.index ["schools_school_profile_id"], name: "index_phase_subjects_on_school_profile_id"
  end

  create_table "schools_school_profiles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "urn", null: false
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
    t.string "dbs_fee_interval"
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
    t.index ["urn"], name: "index_schools_school_profiles_on_urn"
  end

  add_foreign_key "bookings_schools", "bookings_school_types"
  add_foreign_key "bookings_schools_phases", "bookings_phases"
  add_foreign_key "bookings_schools_phases", "bookings_schools"
  add_foreign_key "bookings_schools_subjects", "bookings_schools"
  add_foreign_key "bookings_schools_subjects", "bookings_subjects"
  add_foreign_key "schools_on_boarding_phase_subjects", "bookings_phases"
  add_foreign_key "schools_on_boarding_phase_subjects", "bookings_subjects"
  add_foreign_key "schools_on_boarding_phase_subjects", "schools_school_profiles"
end
