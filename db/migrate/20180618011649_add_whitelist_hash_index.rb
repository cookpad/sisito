class AddWhitelistHashIndex < ActiveRecord::Migration[5.1]
  def change
    add_index :whitelist_mails, :digest
  end
end
