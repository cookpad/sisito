class StatsController < ApplicationController
  RECENT_DAYS = 14

  def index
    # Recently Bounced
    @count_by_date = cache_if_production(:count_by_date, expires_in: 5.minutes) do
      cbd = BounceMail.where('timestamp >= NOW() - INTERVAL ? DAY', RECENT_DAYS)
                .group(:date)
                .pluck('DATE(timestamp) AS date', 'COUNT(1) AS count')
                .sort_by(&:first).to_h

      today = Date.today
      ((today - (RECENT_DAYS - 1).days)..today).map {|d| [d, cbd.fetch(d, 0)] }.to_h
    end

    @count_by_destination = cache_if_production(:count_by_destination, expires_in: 5.minutes) do
      BounceMail.where('timestamp >= NOW() - INTERVAL ? DAY', RECENT_DAYS)
                .group(:destination).count
                .sort_by(&:last).reverse.to_h
    end

    @count_by_reason = cache_if_production(:count_by_reason, expires_in: 5.minutes) do
      BounceMail.where('timestamp >= NOW() - INTERVAL ? DAY', RECENT_DAYS)
                .group(:reason).count
    end

    # Unique Recipient Bounced
    @uniq_count_by_destination = cache_if_production(:uniq_count_by_destination, expires_in: 1.hour) do
      BounceMail.distinct.group(:destination).count(:recipient)
                .sort_by(&:last).reverse.to_h
    end

    @uniq_count_by_reason = cache_if_production(:uniq_count_by_reason, expires_in: 1.hour) do
      BounceMail.distinct.group(:reason).count(:recipient)
    end

    @uniq_count_by_senderdomain = cache_if_production(:uniq_count_by_senderdomain, expires_in: 1.hour) do
      BounceMail.distinct.group(:senderdomain).count(:recipient)
    end

    # Bounced by Type
    @bounced_by_type = cache_if_production(:bounced_by_type, expires_in: 1.hour) do
      count_by_reason_destination = {}

      BounceMail.group(:reason, :destination).count.each do |(reason, destination), count|
        count_by_reason_destination[reason] ||= {}
        count_by_reason_destination[reason][destination] = count
      end

      count_by_reason_destination
    end
  end

  private

  def cache_if_production(key, options = {}, &block)
    if Rails.env.production?
      Rails.cache.fetch(key, options) do
        yield
      end
    else
      yield
    end
  end
end
