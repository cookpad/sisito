require 'csv'

class AdminController < ApplicationController
  BOUNCE_MAILS_COUNT_PER_PAGE = 10
  REPEAT_THRESHOLD = 5

  before_action :authenticate
  before_action :set_bounce_mail, only: [:show, :destroy]

  def index
    if cookies[:admin_query].present?
      redirect_to admin_search_path
    else
      @bounce_mails = BounceMail.select('bounce_mails.*', 'whitelist_mails.recipient AS whitelisted')
                                .joins('LEFT JOIN whitelist_mails' +
                                       '  ON bounce_mails.recipient = whitelist_mails.recipient ' +
                                       ' AND bounce_mails.senderdomain = whitelist_mails.senderdomain')
                                .group(:recipient, :senderdomain)
                                .order(:recipient)
                                .page(params[:page]).per(BOUNCE_MAILS_COUNT_PER_PAGE)

      @repeated_bounced_reason = params[:repeated_bounced_reason]
      repeated_bounce_mails_where = {'whitelist_mails.recipient' => nil}
      repeated_bounce_mails_where[:reason] = @repeated_bounced_reason if @repeated_bounced_reason.present?

      @repeated_bounce_mails = BounceMail.select('bounce_mails.*', 'COUNT(*) AS count', 'whitelist_mails.recipient AS whitelisted')
                                         .joins('LEFT JOIN whitelist_mails' +
                                                '  ON bounce_mails.recipient = whitelist_mails.recipient ' +
                                                ' AND bounce_mails.senderdomain = whitelist_mails.senderdomain')
                                         .where(repeated_bounce_mails_where)
                                         .group(:recipient, :senderdomain)
                                         .having('count >= ?', REPEAT_THRESHOLD)
                                         .sort_by {|i| -i.count }

      @bounce_overs = BounceMail.select('bounce_mails.*', 'whitelist_mails.recipient AS whitelisted')
                                .joins('INNER JOIN whitelist_mails' +
                                       '  ON bounce_mails.recipient = whitelist_mails.recipient ' +
                                       ' AND bounce_mails.senderdomain = whitelist_mails.senderdomain' +
                                       ' AND bounce_mails.timestamp > whitelist_mails.created_at')
                                .group(:recipient, :senderdomain)
                                .order(:recipient)
    end
  end

  def search
    @query = params[:query] || cookies[:admin_query]
    phrases = @query.split(/\s+/)

    if (params[:commit] == 'Search' and @query.blank?) or params[:commit] == 'Clear'
      cookies.delete(:admin_query)
      redirect_to admin_index_path
    else
      cookies[:admin_query] = @query

      @bounce_mails = BounceMail.select('bounce_mails.*', 'whitelist_mails.recipient AS whitelisted')
                                .joins('LEFT JOIN whitelist_mails' +
                                       '  ON bounce_mails.recipient = whitelist_mails.recipient ' +
                                       ' AND bounce_mails.senderdomain = whitelist_mails.senderdomain')
                                .where(phrases.map { 'bounce_mails.recipient LIKE ?' }.join('OR'), *phrases)
                                .group(:recipient, :senderdomain)
                                .order(:recipient)
      render :index
    end
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
                             .group(:recipient, :senderdomain)
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
    @bounce_mail = BounceMail.select('bounce_mails.*', 'whitelist_mails.recipient AS whitelisted', 'MAX(whitelist_mails.created_at) AS max_whitelist_mail_created_at')
                             .joins('LEFT JOIN whitelist_mails' +
                                    '  ON bounce_mails.recipient = whitelist_mails.recipient ' +
                                    ' AND bounce_mails.senderdomain = whitelist_mails.senderdomain')
                             .find(params[:id])
  end
end
