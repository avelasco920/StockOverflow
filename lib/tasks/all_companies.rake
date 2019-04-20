namespace :all_companies do
  desc "Updates stock price cache for all companies"
  task update_stock_prices: :environment do
    Company.all.each.with_index do |company, count|
      company.clear_old_stock_prices
      FetchStockPricesJob.set(wait: 1.minute * count).perform_later(company)
    end
  end

end