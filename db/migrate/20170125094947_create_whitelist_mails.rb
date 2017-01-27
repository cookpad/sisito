class CreateWhitelistMails < ActiveRecord::Migration[5.0]
  def change
    create_table "whitelist_mails", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.string   "recipient"
      t.string   "destination", default: "", null: false
      t.datetime "created_at",               null: false
      t.datetime "updated_at",               null: false
      t.index ["recipient", "destination"], name: "idx_recipient_destination", unique: true, using: :btree
    end

    add_foreign_key "whitelist_mails", "bounce_mails", column: "recipient", primary_key: "recipient", name: "whitelist_mails_ibfk_1", on_update: :cascade, on_delete: :cascade
  end
end
