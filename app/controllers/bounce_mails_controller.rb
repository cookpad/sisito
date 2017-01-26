class BounceMailsController < ApplicationController
  before_action :set_bounce_mail, only: [:show]

  def index
    @query = params[:query] || cookies[:query]

    @count_by_date = BounceMail.where('timestamp >= NOW() - INTERVAL 30 DAY')
                               .group(:date)
                               .pluck('DATE(timestamp) AS date', 'COUNT(1) AS count')
                               .sort_by(&:first).to_h

    @count_by_destination = BounceMail.where('timestamp >= NOW() - INTERVAL 30 DAY')
                                      .group(:destination).count

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

      {recipient: recipients, digest: digests}.each do |k, v|
        if v.present?
          @bounce_mails += BounceMail.select(:id, 'MAX(timestamp) AS timestamp', :recipient)
                                     .where(k => v).group(:recipient)
        end
      end
    end
  end

  def show
    @history = BounceMail.where(recipient: @bounce_mail.recipient)
                         .order(timestamp: :desc)
  end

  private

  def set_bounce_mail
    @bounce_mail = BounceMail.find(params[:id])
  end
end
