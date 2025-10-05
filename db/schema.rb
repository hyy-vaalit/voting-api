# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2025_10_05_153029) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "alliances", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.integer "election_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "numbering_order"
    t.string "short_name", null: false
    t.integer "coalition_id", null: false
    t.index ["coalition_id"], name: "index_alliances_on_coalition_id"
  end

  create_table "candidates", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "alliance_id", null: false
    t.string "firstname", null: false
    t.string "lastname", null: false
    t.integer "candidate_number"
    t.string "candidate_name"
  end

  create_table "coalitions", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "short_name"
    t.integer "numbering_order"
    t.integer "election_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["election_id"], name: "index_coalitions_on_election_id"
  end

  create_table "delayed_jobs", id: :serial, force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at", precision: nil
    t.datetime "locked_at", precision: nil
    t.datetime "failed_at", precision: nil
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "departments", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.integer "faculty_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["code"], name: "index_departments_on_code", unique: true
  end

  create_table "elections", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "faculties", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "abbreviation", null: false
    t.index ["abbreviation"], name: "index_faculties_on_abbreviation", unique: true
    t.index ["code"], name: "index_faculties_on_code", unique: true
  end

  create_table "immutable_votes", id: :serial, force: :cascade do |t|
    t.integer "candidate_id", null: false
    t.integer "election_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["candidate_id"], name: "index_immutable_votes_on_candidate_id"
    t.index ["election_id"], name: "index_immutable_votes_on_election_id"
  end

  create_table "voters", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "email"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "faculty_id"
    t.string "ssn", null: false
    t.string "student_number"
    t.integer "start_year"
    t.integer "extent_of_studies"
    t.string "phone"
    t.integer "department_id"
    t.index ["email"], name: "index_voters_on_email"
  end

  create_table "voting_rights", id: :serial, force: :cascade do |t|
    t.integer "election_id", null: false
    t.integer "voter_id", null: false
    t.boolean "used", default: false, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["election_id"], name: "index_voting_rights_on_election_id"
    t.index ["voter_id", "election_id"], name: "index_voting_rights_on_voter_id_and_election_id", unique: true
    t.index ["voter_id"], name: "index_voting_rights_on_voter_id"
  end

  add_foreign_key "alliances", "coalitions"
  add_foreign_key "alliances", "elections"
  add_foreign_key "candidates", "alliances"
  add_foreign_key "departments", "faculties"
  add_foreign_key "immutable_votes", "candidates"
  add_foreign_key "immutable_votes", "elections"
  add_foreign_key "voters", "departments"
  add_foreign_key "voters", "faculties"
  add_foreign_key "voting_rights", "elections"
  add_foreign_key "voting_rights", "voters"
end
