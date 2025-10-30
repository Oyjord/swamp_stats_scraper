# lib/parser.rb
require 'nokogiri'

module Parser
  def self.extract_stats(doc)
    skaters = []
    goalies = []

    doc.css('section').each do |section|
      heading = section.at_css('h2')&.text&.strip&.downcase
      next unless heading

      table = section.at_css('table')
      next unless table

      rows = table.css('tbody tr')
      headers = table.css('thead tr th').map { |th| th.text.strip.downcase }

      rows.each do |row|
        cells = row.css('td').map { |td| td.text.strip }
        next if cells.empty?

        player = Hash[headers.zip(cells)]
        player['name'] = player.delete('player') || player.delete('name')

        if heading.include?('goalie')
          goalies << player
        else
          skaters << player
        end
      end
    end

    { "skaters" => skaters, "goalies" => goalies }
  end
end
