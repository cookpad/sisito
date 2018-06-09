class AddWhitelistHash < ActiveRecord::Migration[5.1]
  def change
    add_column :whitelist_mails, :digest, :string, after: :senderdomain

    algorithm = Rails.application.config.sisito.fetch(:digest)

    WhitelistMail.find_in_batches do |whitelist_mails|
      whitelist_mails.each do |wm|
        digest = algorithm.hexdigest(wm.recipient)
        WhitelistMail.where(id: wm.id).update_all(digest: digest)
      end
    end

    change_column_null :whitelist_mails, :digest, false
  end
end
