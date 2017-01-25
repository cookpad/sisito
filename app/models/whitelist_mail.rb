class WhitelistMail < ApplicationRecord
  validates :recipient, presence: true
  validates :recipient, format: { with: /.+@.+/ }
end
