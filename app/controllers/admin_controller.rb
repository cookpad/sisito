class AdminController < ApplicationController
  USERS = { "hello" => "world" }

  before_action :authenticate, if: -> { Rails.env.production? }
  before_action :set_bounce_mail, only: [:show]

  def index
    @bounce_mails = BounceMail.select(:id, 'MAX(timestamp) AS timestamp', :recipient, :senderdomain, :reason)
                               .joins('LEFT JOIN whitelist_mails' +
                                      '  ON bounce_mails.recipient = whitelist_mails.recipient ' +
                                      ' AND bounce_mails.senderdomain = whitelist_mails.senderdomain')
                               .where('whitelist_mails.recipient IS NULL')
                               .group(:recipient)
                               .page(params[:page])
  end

  def show
    @history = BounceMail.where(recipient: @bounce_mail.recipient, senderdomain: @bounce_mail.senderdomain)
                         .order(timestamp: :desc)
  end

  private

  def authenticate
    authenticate_or_request_with_http_digest do |username|
      USERS[username]
    end
  end

  private

  def set_bounce_mail
    @bounce_mail = BounceMail.find(params[:id])
  end
end
