class BounceMailsController < ApplicationController
  before_action :set_bounce_mail, only: [:show]

  def index
    @query = params[:query] || cookies[:query]

    if (params[:commit] == 'Search' and @query.blank?) or params[:commit] == 'Clear'
      cookies[:query] = ''
      redirect_to bounce_mails_path
    else
      @count_by_date = BounceMail.where('timestamp >= NOW() - INTERVAL 7 DAY')
                                 .group(:date)
                                 .pluck('DATE(timestamp) AS date', 'COUNT(1) AS count')
                                 .sort_by(&:first).to_h

      @count_by_senderdomain = BounceMail.where('timestamp >= NOW() - INTERVAL 7 DAY')
                                        .group(:senderdomain).count

      @count_by_reason = BounceMail.where('timestamp >= NOW() - INTERVAL 7 DAY')
                                        .group(:reason).count

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

  def set_bounce_mail
    @bounce_mail = BounceMail.find(params[:id])
  end
end
