# == Schema Information
#
# Table name: companies
#
#  id            :integer          not null, primary key
#  name          :string           not null
#  symbol        :string           not null
#  market_price  :float
#  biography     :string
#  ceo           :string
#  founding_year :integer
#  employees     :integer
#  location      :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Company < ApplicationRecord
  validates :name, :symbol, presence: true, uniqueness: true
  has_many :trade_events, dependent: :destroy
  has_many :stock_prices, dependent: :destroy
  has_many :stocks, dependent: :destroy
  has_many :watchlist_items, dependent: :destroy
  has_many :news_articles, dependent: :destroy

  def market_price
    self.stock_prices.order(time: :desc).first&.price
  end

  def individual_stock_value(num_shares)
    self.market_price * num_shares
  end

  def self.top_five_by_name(query_params)
    param = '%' + query_params.downcase + '%'
    Company.where('lower(name) LIKE ?', param).limit(5)
  end

  def self.top_five_by_symbol(query_params)
    param = '%' + query_params.downcase + '%'
    Company.where('lower(symbol) LIKE ?', param).limit(5)
  end

  def update_stock_prices(time_series)
    return if !['intraday', 'daily'].include?(time_series)
    interval = time_series == 'intraday' ? '5min' : 'daily'
    response = RestClient::Request.execute(
      method: :get,
      url: "https://www.alphavantage.co/query?function=TIME_SERIES_#{time_series.upcase}&symbol=#{self.symbol}&interval=#{interval}&outputsize=full&apikey=#{ENV['ALPHAVANTAGE_API_KEY']}",
    )

    parsed_response = JSON.parse(response)
    return if parsed_response['Error Message']

    time_series_data = parsed_response["Time Series (#{interval.capitalize})"]

    time_parse_format = time_series == 'daily' ? '%F' : '%F %T'

    times = time_series_data
      .keys
      .map do |time|
        time.in_time_zone('EST')
      end
    existing_times = StockPrice
      .where(company: self, time_series: time_series, time: times)
      .pluck(:time)
      .map do |time|
        time.in_time_zone('EST').strftime(time_parse_format)
      end
    new_prices = time_series_data
      .reject do |time, v|
        existing_times.include?(time)
      end

    new_prices.each do |time, price_data|
      adjusted_time = Time.find_zone('EST').parse(time)
      current_time = Time.current.in_time_zone('EST')
      next if adjusted_time < current_time - 1.year
      next if time_series == 'intraday' && adjusted_time < (current_time - 1.week)
      if time_series == 'intraday' && adjusted_time.hour == 16
        self
          .stock_prices
          .find_or_create_by(
            time: adjusted_time.beginning_of_day,
            price: price_data['4. close'],
            time_series: 'daily'
        )
      end
      self
        .stock_prices
        .find_or_create_by(
          time: adjusted_time,
          price: price_data['4. close'],
          time_series: time_series
      )
    end
  end
end
