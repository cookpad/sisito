require 'csv'

class AdminController < ApplicationController
  before_action :authenticate
  before_action :set_bounce_mail, only: [:show, :destroy]

  def index
    @bounce_mails = BounceMail.select(:id, :recipient, :senderdomain, :reason, 'whitelist_mails.recipient AS whitelisted')
                               .joins('LEFT JOIN whitelist_mails' +
                                      '  ON bounce_mails.recipient = whitelist_mails.recipient ' +
                                      ' AND bounce_mails.senderdomain = whitelist_mails.senderdomain')
                               .group(:recipient)
                               .order(:recipient)
                               .page(params[:page])
  end

  def show
    @history = BounceMail.where(recipient: @bounce_mail.recipient, senderdomain: @bounce_mail.senderdomain)
                         .order(timestamp: :desc)
  end

  def destroy
    BounceMail.delete_all(recipient: @bounce_mail.recipient, senderdomain: @bounce_mail.senderdomain)
    redirect_to admin_index_path, notice: 'Whitelist mail was successfully destroyed.'
  end

  def download
    csv = CSV.generate do |rows|
      rows << BounceMail.column_names

      BounceMail.all.each do |bounce_mail|
        rows << bounce_mail.attributes.values_at(*BounceMail.column_names)
      end
    end

    send_data csv, filename: 'bounce_mails.csv', type: :csv
  end

  private

  def authenticate
    authenticate_or_request_with_http_digest do |username|
      if username == Rails.application.config.admin[:username]
        Rails.application.config.admin[:password]
      end
    end
  end

  def set_bounce_mail
    @bounce_mail = BounceMail.find(params[:id])
  end
end
