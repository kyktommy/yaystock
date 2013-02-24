#!/usr/bin/env ruby

require 'thor'
require 'net/http'
require 'uri'
require 'csv'
require 'terminal-table'

class App < Thor

  desc "stock", "query stock detail <NUMBER>"
  def stock(number)
    print_stock_table do |t|
      t << get_stock_data(number)[0].to_hash.values
    end
  end

  desc "stocks", "query many stocks <NUMBER...>"
  option :numbers, required: true, type: :array
  def stocks
    print_stock_table do |t|
      options[:numbers].each do |number|
        t << get_stock_data(number)[0].to_hash.values  
      end
    end
  end

  private

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

