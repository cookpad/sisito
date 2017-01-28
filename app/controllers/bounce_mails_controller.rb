class BounceMailsController < ApplicationController
  before_action :set_bounce_mail, only: [:show]

  def index
    @query = params[:query] || cookies[:query]

    if (params[:commit] == 'Search' and @query.blank?) or params[:commit] == 'Clear'
      cookies[:query] = ''
      redirect_to bounce_mails_path
    else
      fetch_summary

      if @query.present?
        cookies[:query] = @query
        recipients = []
        digests = []

        @query.split(/\s+/).each do |phrase|
          if phrase =~ /@/
            recipients << phrase
          else
            digests << phrase
          end
        end

        @bounce_mails = []

        {recipient: recipients, digest: digests}.each {|k, v|
          if v.present?
            @bounce_mails += BounceMail.select(:id, 'MAX(timestamp) AS timestamp', :recipient, :senderdomain)
                                       .joins('LEFT JOIN whitelist_mails' +
                                              '  ON bounce_mails.recipient = whitelist_mails.recipient ' +
                                              ' AND bounce_mails.senderdomain = whitelist_mails.senderdomain')
                                       .where('whitelist_mails.recipient IS NULL')
                                       .where(k => v).group(:recipient)
          end
        }
      end
    end
  end

  def show
    @history = BounceMail.where(recipient: @bounce_mail.recipient, senderdomain: @bounce_mail.senderdomain)
                         .order(timestamp: :desc)
  end

  private

  def fetch_summary
    # Recently Bounced
    @count_by_date = Rails.cache.fetch(:count_by_date, expires_in: 5.minutes) do
      BounceMail.where('timestamp >= NOW() - INTERVAL 7 DAY')
                .group(:date)
                .pluck('DATE(timestamp) AS date', 'COUNT(1) AS count')
                .sort_by(&:first).to_h
    end

    @count_by_destination = Rails.cache.fetch(:count_by_destination, expires_in: 5.minutes) do
      BounceMail.where('timestamp >= NOW() - INTERVAL 7 DAY')
                .group(:destination).count
                .sort_by(&:last).reverse.to_h
    end

    @count_by_reason = Rails.cache.fetch(:count_by_reason, expires_in: 5.minutes) do
      BounceMail.where('timestamp >= NOW() - INTERVAL 7 DAY')
                .group(:reason).count
    end

    # Total Unique Recipient Bounced
    @uniq_count_by_destination = Rails.cache.fetch(:uniq_count_by_destination, expires_in: 1.hour) do
      BounceMail.uniq.group(:destination).count(:recipient)
                .sort_by(&:last).reverse.to_h
    end

    @uniq_count_by_reason = Rails.cache.fetch(:uniq_count_by_reason, expires_in: 1.hour) do
      BounceMail.uniq.group(:reason).count(:recipient)
    end
  end

  def set_bounce_mail
    @bounce_mail = BounceMail.find(params[:id])
  end
end
