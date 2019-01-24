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

ActiveRecord::Schema.define(version: 2019_01_24_145221) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "bookings_phases", force: :cascade do |t|
    t.string "name", limit: 32
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_bookings_phases_on_name"
  end

  create_table "bookings_schools", force: :cascade do |t|
    t.string "name", limit: 128, null: false
    t.geography "coordinates", limit: {:srid=>4326, :type=>"st_point", :geographic=>true}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["coordinates"], name: "index_bookings_schools_on_coordinates", using: :gist
    t.index ["name"], name: "index_bookings_schools_on_name"
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
    t.string "name", limit: 64
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_bookings_subjects_on_name"
  end

  add_foreign_key "bookings_schools_phases", "bookings_phases"
  add_foreign_key "bookings_schools_phases", "bookings_schools"
  add_foreign_key "bookings_schools_subjects", "bookings_schools"
  add_foreign_key "bookings_schools_subjects", "bookings_subjects"
end
