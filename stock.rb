#!/usr/bin/env ruby

%w{thor net/http uri csv terminal-table}
.map { |lib| require lib }

class App < Thor

  desc "stock", "query stock detail <NUMBER>"
  def stock(number)
    print_stock_table do |t|
      t << latest_stock_price(number)
    end
  end

  desc "stocks", "query many stocks <NUMBERS...>"
  option :numbers, required: true, type: :array, aliases: "-n"
  def stocks
    print_stock_table do |t|
      options[:numbers].each do |number|
        t << latest_stock_price(number)
      end
    end
  end

  private

  def latest_stock_price(number)
    get_stock_data(number).first.to_hash.values
  end

  def print_stock_table
    table = Terminal::Table.new(headings: stock_header) do |t|
      yield t
    end
    puts table
  end

  def stock_header
    %w{ Date Open High Low Close Volume Adj_Close }
  end

  def get_stock_data(number)
    uri = URI.parse("http://ichart.yahoo.com/table.csv?s=#{number}.HK")
    response = Net::HTTP.get_response(uri)
    csv = CSV.parse(response.body, headers: true)
    csv.inject([]) {|rows, row| rows << row } 
  end
   
end

App.start ARGV

