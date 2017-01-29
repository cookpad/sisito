class ConfirmationMail
  include ActiveModel::Model

  attr_accessor :from, :to, :subject, :body

  validates :from, presence: true
  validates :to, presence: true
  validates :to, format: { with: /.+@.+/ }
  validates :subject, presence: true
  validates :body, presence: true

  def save
    if self.valid?
      ConfirmationMailer.email(self).deliver!
    end
  end
end
