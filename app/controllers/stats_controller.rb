class StatsController < ApplicationController
  def index
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

    # Unique Recipient Bounced
    @uniq_count_by_destination = Rails.cache.fetch(:uniq_count_by_destination, expires_in: 1.hour) do
      BounceMail.uniq.group(:destination).count(:recipient)
                .sort_by(&:last).reverse.to_h
    end

    @uniq_count_by_reason = Rails.cache.fetch(:uniq_count_by_reason, expires_in: 1.hour) do
      BounceMail.uniq.group(:reason).count(:recipient)
    end

    @uniq_count_by_senderdomain = Rails.cache.fetch(:uniq_count_by_senderdomain, expires_in: 1.hour) do
      BounceMail.uniq.group(:senderdomain).count(:recipient)
    end
  end
end
