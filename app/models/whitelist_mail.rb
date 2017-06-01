class WhitelistMail < ApplicationRecord
  validates :recipient, presence: true
  validates :recipient, format: { with: /.+@.+/ }
  validates :senderdomain, presence: true

  has_many :bounce_mails, primary_key: 'recipient', foreign_key: 'recipient'
end
