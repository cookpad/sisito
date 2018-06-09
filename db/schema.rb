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

ActiveRecord::Schema.define(version: 20180609030108) do

  create_table "bounce_mails", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.datetime "timestamp", null: false
    t.string "lhost", null: false
    t.string "rhost", null: false
    t.string "alias", null: false
    t.string "listid", null: false
    t.string "reason", null: false
    t.string "action", null: false
    t.string "subject", null: false
    t.string "messageid", null: false
    t.string "smtpagent", null: false
    t.boolean "softbounce", null: false
    t.string "smtpcommand", null: false
    t.string "destination", null: false
    t.string "senderdomain", null: false
    t.string "feedbacktype", null: false
    t.string "diagnosticcode", null: false
    t.string "deliverystatus", null: false
    t.string "timezoneoffset", null: false
    t.string "addresser", null: false
    t.string "addresseralias", null: false
    t.string "recipient", null: false
    t.string "digest", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["addresser"], name: "idx_addresser_senderdomain"
    t.index ["destination"], name: "idx_destination"
    t.index ["digest"], name: "idx_digest"
    t.index ["messageid"], name: "idx_messageid"
    t.index ["reason", "recipient"], name: "idx_reason_recipient"
    t.index ["recipient"], name: "idx_recipient"
    t.index ["senderdomain"], name: "idx_senderdomain"
    t.index ["softbounce", "recipient"], name: "idx_softbounce_recipient"
    t.index ["timestamp"], name: "idx_timestamp"
  end

  create_table "whitelist_mails", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "recipient", default: "", null: false
    t.string "senderdomain", default: "", null: false
    t.string "digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "idx_created_at"
    t.index ["recipient", "senderdomain"], name: "idx_recipient_senderdomain", unique: true
  end

end
