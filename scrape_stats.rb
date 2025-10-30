# scrape_stats.rb
require 'nokogiri'
require 'open-uri'
require 'json'
require_relative 'lib/parser'

url = 'https://echl.com/teams/greenville-swamp-rabbits'
html = URI.open(url).read
doc = Nokogiri::HTML(html)

stats = Parser.extract_stats(doc)

File.write('data/swamp_stats.json', JSON.pretty_generate(stats))
puts "✅ Wrote #{stats["skaters"].size} skaters and #{stats["goalies"].size} goalies to data/swamp_stats.json"
