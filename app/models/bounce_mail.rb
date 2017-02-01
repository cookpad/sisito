class BounceMail < ApplicationRecord
  def mask_recipient
    user, domain = self.recipient.split('@', 2)
    user.gsub!(/./, '*')
    [user, domain].join(?@)
  end
end
