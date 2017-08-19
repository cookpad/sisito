require 'csv'

class AdminController < ApplicationController
  BOUNCE_MAILS_COUNT_PER_PAGE = 10
  REPEAT_THRESHOLD = 5
  RECENT_DAYS = 14

  unless Rails.application.config.sisito.fetch(:authz).fetch(:show_admin)
    before_action :authenticate
  end

  before_action :set_bounce_mail, only: [:show, :destroy]

  def index
    if cookies[:admin_query].present?
      redirect_to admin_search_path
    else
      @repeated_bounced_reason = params[:repeated_bounced_reason]

      @repeated_bounce_mails = cache_if_production(:admin_repeated_bounce_mails, expires_in: 10.minutes) do
        rbm = BounceMail.select('bounce_mails.*', 'COUNT(*) AS count', 'whitelist_mails.id AS whitelisted')
                        .joins('LEFT JOIN whitelist_mails' +
                               '  ON bounce_mails.recipient = whitelist_mails.recipient ' +
                               ' AND bounce_mails.senderdomain = whitelist_mails.senderdomain')
                        .where('whitelist_mails.recipient' => nil)
                        .where('timestamp >= NOW() - INTERVAL ? DAY', RECENT_DAYS)

        if @repeated_bounced_reason
          rbm = rbm.where(reason: @repeated_bounced_reason)
        end

        rbm.group(:recipient, :senderdomain)
           .having('count >= ?', REPEAT_THRESHOLD)
           .sort_by {|i| -i.count }
      end

      @bounce_overs = cache_if_production(:admin_bounce_overs, expires_in: 10.minutes) do
        bounce_over_buf = Rails.application.config.sisito.dig(:bounce_over, :buffer) || 0

        BounceMail.select('bounce_mails.*', 'whitelist_mails.id AS whitelisted')
                  .joins('INNER JOIN whitelist_mails' +
                         '  ON bounce_mails.recipient = whitelist_mails.recipient ' +
                         ' AND bounce_mails.senderdomain = whitelist_mails.senderdomain' +
                         " AND bounce_mails.timestamp > (whitelist_mails.created_at + INTERVAL #{bounce_over_buf} SECOND)")
                  .where('timestamp >= NOW() - INTERVAL ? DAY', RECENT_DAYS)
                  .group(:recipient, :senderdomain)
                  .order(:recipient)
      end
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

      @bounce_mails = BounceMail.select('bounce_mails.*', 'whitelist_mails.id AS whitelisted')
                                .joins('LEFT JOIN whitelist_mails' +
                                       '  ON bounce_mails.recipient = whitelist_mails.recipient ' +
                                       ' AND bounce_mails.senderdomain = whitelist_mails.senderdomain')
                                .where(phrases.map { 'bounce_mails.recipient LIKE ?' }.join('OR'), *phrases)
                                .group(:recipient, :senderdomain)
                                .order(:recipient)
                                .page(params[:page]).per(BOUNCE_MAILS_COUNT_PER_PAGE)
      render :index
    end
  end

  def show
    @history = BounceMail.where(recipient: @bounce_mail.recipient, senderdomain: @bounce_mail.senderdomain)
                         .order(timestamp: :desc)
                         .page(params[:page])
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

    column_names = %w(recipient addresser addresseralias reason whitelisted)

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
    @bounce_mail = BounceMail.select('bounce_mails.*', 'whitelist_mails.id AS whitelisted', 'MAX(whitelist_mails.created_at) AS max_whitelist_mail_created_at')
                             .joins('LEFT JOIN whitelist_mails' +
                                    '  ON bounce_mails.recipient = whitelist_mails.recipient ' +
                                    ' AND bounce_mails.senderdomain = whitelist_mails.senderdomain')
                             .find(params[:id])

    if @bounce_mail.whitelisted
      @whitelist_mail = WhitelistMail.find(@bounce_mail.whitelisted)
    end
  end
end
