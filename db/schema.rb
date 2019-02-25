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

ActiveRecord::Schema.define(version: 2019_02_25_092622) do

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

  create_table "candidates_registrations_placement_requests", force: :cascade do |t|
    t.date "date_start", null: false
    t.date "date_end", null: false
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

  add_foreign_key "bookings_schools", "bookings_school_types"
  add_foreign_key "bookings_schools_phases", "bookings_phases"
  add_foreign_key "bookings_schools_phases", "bookings_schools"
  add_foreign_key "bookings_schools_subjects", "bookings_schools"
  add_foreign_key "bookings_schools_subjects", "bookings_subjects"
end
