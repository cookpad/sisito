require 'csv'

class AdminController < ApplicationController
  before_action :authenticate
  before_action :set_bounce_mail, only: [:show, :destroy]

  def index
    @bounce_mails = BounceMail.select('bounce_mails.*', 'whitelist_mails.recipient AS whitelisted')
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
    bounce_mails = BounceMail.select('bounce_mails.*', 'IF(whitelist_mails.recipient IS NULL, 0, 1) AS whitelisted')
                             .joins('LEFT JOIN whitelist_mails' +
                                    '  ON bounce_mails.recipient = whitelist_mails.recipient ' +
                                    ' AND bounce_mails.senderdomain = whitelist_mails.senderdomain')
                             .group(:recipient)
                             .order(:recipient)

    column_names = %w(recipient senderdomain reason whitelisted)

    csv = CSV.generate do |rows|
      rows << column_names

      bounce_mails.each do |bounce_mail|
        rows << bounce_mail.attributes.values_at(*column_names)
      end
    end

    send_data csv, filename: 'bounce_mails.csv', type: :csv
  end

  private

  def authenticate
    sisito_config = Rails.application.config.sisito

    authenticate_or_request_with_http_digest do |username|
      if username == sisito_config.fetch(:admin).fetch(:username)
        sisito_config.fetch(:admin).fetch(:password)
      end
    end
  end

  def set_bounce_mail
    @bounce_mail = BounceMail.select('bounce_mails.*', 'whitelist_mails.recipient AS whitelisted')
                             .joins('LEFT JOIN whitelist_mails' +
                                    '  ON bounce_mails.recipient = whitelist_mails.recipient ' +
                                    ' AND bounce_mails.senderdomain = whitelist_mails.senderdomain')
                             .find(params[:id])
  end
end
