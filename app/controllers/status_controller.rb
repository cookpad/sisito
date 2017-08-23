class StatusController < ApplicationController
  def index
    interval = (Rails.application.config.sisito.dig(:status, :interval) || 60).to_i
    start_time = Time.now - interval

    status = cache_if_production(:status, expires_in: interval - 5) do
      bounce_mails = BounceMail.where('timestamp >= ?', start_time - interval).to_a

      {
        start_time: start_time,
        interval: interval,
        count: {
          all: bounce_mails.count,
          reason: bounce_mails.group_by {|m| m.reason }.map {|r, ms| [r, ms.count] }.to_h,
          senderdomain: bounce_mails.group_by {|m| m.senderdomain }.map {|r, ms| [r, ms.count] }.to_h,
          destination: bounce_mails.group_by {|m| m.destination }.map {|r, ms| [r, ms.count] }.to_h,
        },
      }
    end

    render json: status
  end
end
