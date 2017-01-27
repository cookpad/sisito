class WhitelistMail < ApplicationRecord
  validates :recipient, presence: true
  validates :recipient, format: { with: /.+@.+/ }
  validates :senderdomain, presence: true
end
