class CreateBounceMails < ActiveRecord::Migration[5.0]
  def change
    create_table "bounce_mails" do |t|
      t.datetime "timestamp",                   null: false
      t.string   "lhost",                       null: false
      t.string   "rhost",                       null: false
      t.string   "alias",                       null: false
      t.string   "listid",                      null: false
      t.string   "reason",                      null: false
      t.string   "action",                      null: false
      t.string   "subject",                     null: false
      t.string   "messageid",                   null: false
      t.string   "smtpagent",                   null: false
      t.boolean  "softbounce",                  null: false
      t.string   "smtpcommand",                 null: false
      t.string   "destination",                 null: false
      t.string   "senderdomain",                null: false
      t.string   "feedbacktype",                null: false
      t.string   "diagnosticcode",              null: false
      t.string   "deliverystatus",              null: false
      t.string   "timezoneoffset",              null: false
      t.string   "addresser",                   null: false
      t.string   "addresseralias"
      t.string   "recipient",                   null: false
      t.string   "digest",         default: "", null: false
      t.datetime "created_at",                  null: false
      t.datetime "updated_at",                  null: false
      t.index ["addresser"], name: "idx_addresser_senderdomain", using: :btree
      t.index ["destination"], name: "idx_destination", using: :btree
      t.index ["digest"], name: "idx_digest", using: :btree
      t.index ["messageid"], name: "idx_messageid", using: :btree
      t.index ["reason", "recipient"], name: "idx_reason_recipient", using: :btree
      t.index ["recipient"], name: "idx_recipient", using: :btree
      t.index ["senderdomain"], name: "idx_senderdomain", using: :btree
      t.index ["softbounce", "recipient"], name: "idx_softbounce_recipient", using: :btree
      t.index ["timestamp"], name: "idx_timestamp", using: :btree
    end
  end
end
