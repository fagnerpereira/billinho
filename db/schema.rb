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

ActiveRecord::Schema.define(version: 20180905121929) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "institutions", force: :cascade do |t|
    t.string "name"
    t.integer "cnpj"
    t.string "kind"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_institutions_on_user_id"
  end

  create_table "registrations", force: :cascade do |t|
    t.float "amount"
    t.integer "bills_count"
    t.integer "bill_expiry_day"
    t.string "course_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "institution_id"
    t.bigint "student_id"
    t.index ["institution_id"], name: "index_registrations_on_institution_id"
    t.index ["student_id"], name: "index_registrations_on_student_id"
  end

  create_table "students", force: :cascade do |t|
    t.string "name"
    t.date "birthday"
    t.integer "phone_number"
    t.string "gender"
    t.string "payment_method"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "cpf"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.uuid "access_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "institutions", "users"
  add_foreign_key "registrations", "institutions"
  add_foreign_key "registrations", "students"
end
