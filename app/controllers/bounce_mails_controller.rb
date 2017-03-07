class BounceMailsController < ApplicationController
  before_action :set_bounce_mail, only: [:show]

  def index
    if params[:reason].present?
      cookies.delete(:query)
    else
      @query = params[:query] || cookies[:query]
    end

    if (params[:commit] == 'Search' and @query.blank?) or params[:commit] == 'Clear'
      cookies.delete(:query)
      redirect_to bounce_mails_path
    else
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
            @bounce_mails += BounceMail.select(:id, 'MAX(timestamp) AS timestamp', :recipient, :senderdomain, :reason, :digest,
                                               'whitelist_mails.id AS whitelisted')
                                       .joins('LEFT JOIN whitelist_mails' +
                                              '  ON bounce_mails.recipient = whitelist_mails.recipient ' +
                                              ' AND bounce_mails.senderdomain = whitelist_mails.senderdomain')
                                       .where(k => v).group(:recipient, :senderdomain)
          end
        }
      else
        @bounce_mails = BounceMail.joins('LEFT JOIN whitelist_mails' +
                                         '  ON bounce_mails.recipient = whitelist_mails.recipient ' +
                                         ' AND bounce_mails.senderdomain = whitelist_mails.senderdomain')

        if params[:reason].present?
          @reason = params[:reason]
          @bounce_mails = @bounce_mails.where(reason: @reason)
        end

        @bounce_mails = @bounce_mails.order(timestamp: :desc).page(params[:page])
        @mask = true
      end
    end
  end

  def show
    if @bounce_mail.digest != params[:digest]
      authenticate
    end

    @history = BounceMail.where(recipient: @bounce_mail.recipient, senderdomain: @bounce_mail.senderdomain)
                         .order(timestamp: :desc)
  end

  private

  def set_bounce_mail
    @bounce_mail = BounceMail.select('bounce_mails.*', 'whitelist_mails.id AS whitelisted', 'MAX(whitelist_mails.created_at) AS max_whitelist_mail_created_at')
                             .joins('LEFT JOIN whitelist_mails' +
                                    '  ON bounce_mails.recipient = whitelist_mails.recipient ' +
                                    ' AND bounce_mails.senderdomain = whitelist_mails.senderdomain')
                             .group(:recipient, :senderdomain)
                             .find(params[:id])
  end

  def authenticate
    sisito_config = Rails.application.config.sisito

    authenticate_or_request_with_http_digest do |username|
      if username == sisito_config.fetch(:admin).fetch(:username)
        sisito_config.fetch(:admin).fetch(:password)
      end
    end
  end
end
