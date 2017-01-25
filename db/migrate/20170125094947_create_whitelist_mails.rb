class CreateWhitelistMails < ActiveRecord::Migration[5.0]
  def change
    create_table "whitelist_mails" do |t|
      t.string   "recipient"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["recipient"], name: "idx_recipient", unique: true, using: :btree
    end
  end
end
