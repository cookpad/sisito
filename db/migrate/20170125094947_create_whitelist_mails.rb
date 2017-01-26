class CreateWhitelistMails < ActiveRecord::Migration[5.0]
  def change
    create_table "whitelist_mails" do |t|
      t.string   "recipient"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["recipient"], name: "idx_recipient", unique: true, using: :btree
    end

    add_foreign_key "whitelist_mails", "bounce_mails", column: "recipient", primary_key: "recipient", name: "whitelist_mails_ibfk_1", on_update: :cascade, on_delete: :cascade
  end
end
