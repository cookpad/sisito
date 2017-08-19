class StatsController < ApplicationController
  MAX_RECENT_DAYS = 14

  def index
    @recent_days = (params[:recent_days] || MAX_RECENT_DAYS).to_i
    @addresser = params[:addresser]

    # Recently Bounced
    @count_by_date = cache_if_production("count_by_date_#{@recent_days}_#{@addresser}", expires_in: 5.minutes) do
      relation = BounceMail.where('timestamp >= NOW() - INTERVAL ? DAY', @recent_days)

      relation = relation.where(addresser: @addresser) if @addresser.present?

      cbd = relation.group(:date)
                    .pluck('DATE(timestamp) AS date', 'COUNT(1) AS count')
                    .sort_by(&:first).to_h

      today = Date.today
      ((today - (@recent_days - 1).days)..today).map {|d| [d, cbd.fetch(d, 0)] }.to_h
    end

    @count_by_destination = cache_if_production("count_by_destination_#{@recent_days}_#{@addresser}", expires_in: 5.minutes) do
      relation = BounceMail.where('timestamp >= NOW() - INTERVAL ? DAY', @recent_days)

      relation = relation.where(addresser: @addresser) if @addresser.present?

      relation.group(:destination).count
              .sort_by(&:last).reverse.to_h
    end

    @count_by_reason = cache_if_production("count_by_reason_#{@recent_days}_#{@addresser}", expires_in: 5.minutes) do
      relation = BounceMail.where('timestamp >= NOW() - INTERVAL ? DAY', @recent_days)

      relation = relation.where(addresser: @addresser) if @addresser.present?

      relation.group(:reason).count
              .sort_by(&:last).reverse.to_h
    end

    @count_by_reason_date = cache_if_production("count_by_date_reason_#{@recent_days}_#{@addresser}", expires_in: 5.minutes) do
      relation = BounceMail.select(:reason, "DATE(timestamp) AS date", "COUNT(reason) AS count_reason")
                           .where('timestamp >= NOW() - INTERVAL ? DAY', @recent_days)

      relation = relation.where(addresser: @addresser) if @addresser.present?

      relation.group(:reason, :date)
              .sort_by {|i| [i.reason, i.date] }
              .inject({}) {|r, i| r[i.reason] ||= {}; r[i.reason][i.date] = i.count_reason; r }
    end

    unless Rails.application.config.sisito[:shorten_stats]
      # Unique Recipient Bounced
      @uniq_count_by_destination = cache_if_production("uniq_count_by_destination_#{@addresser}", expires_in: 1.hour) do
        relation = BounceMail

        relation = relation.where(addresser: @addresser) if @addresser.present?

        relation.distinct.group(:destination).count(:recipient)
                .sort_by(&:last).reverse.to_h
      end

      @uniq_count_by_reason = cache_if_production("uniq_count_by_reason_#{@addresser}", expires_in: 1.hour) do
        relation = BounceMail

        relation = relation.where(addresser: @addresser) if @addresser.present?

        relation.distinct.group(:reason).count(:recipient)
                .sort_by(&:last).reverse.to_h
      end

      @uniq_count_by_sender = cache_if_production("uniq_count_by_sender_#{@addresser}", expires_in: 1.hour) do
        select_columns = <<-SQL
          COUNT(DISTINCT recipient) AS count_recipient,
          CASE
          WHEN addresseralias = '' THEN addresser
          ELSE addresseralias
          END AS addresser_alias
        SQL

        relation = BounceMail.select(select_columns)

        relation = relation.where(addresser: @addresser) if @addresser.present?

        relation.group(:addresser_alias)
                .map {|r| [r.addresser_alias, r.count_recipient] }
                .sort_by(&:last).reverse.to_h
      end

      # Bounced by Type
      @bounced_by_type = cache_if_production("bounced_by_type_#{@addresser}", expires_in: 1.hour) do
        count_by_reason_destination = {}

        relation = BounceMail

        relation = relation.where(addresser: @addresser) if @addresser.present?

        relation.group(:reason, :destination).count.each do |(reason, destination), count|
          count_by_reason_destination[reason] ||= {}
          count_by_reason_destination[reason][destination] = count
        end

        count_by_reason_destination
      end
    end
  end
end
