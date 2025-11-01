# lib/parser.rb
require 'nokogiri'

module Parser
  def self.extract_stats(doc)
    skaters = []
    goalies = []

    doc.css('section').each do |section|
      heading = section.at_css('h2, h3, h4')&.text&.strip&.downcase
      warn "🧪 Found section heading: #{heading}" if heading

      table = section.at_css('table')
      next unless table

      rows = table.css('tbody tr')
      headers = table.css('thead tr th').map { |th| th.text.strip.downcase }

      rows.each do |row|
        cells = row.css('td').map { |td| td.text.strip }
        next if cells.empty?

        player = Hash[headers.zip(cells)]
        player['name'] = player.delete('player') || player.delete('name')

       if heading&.match?(/goalie|goalies|goaltending/i)
  goalie = normalize_goalie(player)
  goalies << goalie if goalie
else
  skater = normalize_skater(player)
  skaters << skater if skater
end

      end
    end

    { "skaters" => skaters, "goalies" => goalies }
  end

  def self.normalize_skater(player)
  return nil if player["gp"].nil? || player["gp"].strip.empty?

  {
    "name" => clean_name(player["name"]),
    "gp" => player["gp"]&.to_i,
    "g" => player["g"]&.to_i,
    "a" => player["a"]&.to_i,
    "pts" => player["pts"]&.to_i,
    "plus_minus" => player["+/-"]&.to_i,
    "pim" => player["pim"]&.to_i
  }
end


  def self.normalize_goalie(player)
    {
      "name" => clean_name(player["name"]),
      "gp" => player["gp"]&.to_i,
      "w" => player["w"]&.to_i,
      "l" => player["l"]&.to_i,
      "otl" => player["otl"]&.to_i,
      "gaa" => player["gaa"]&.to_f,
      "sv_percent" => player["sv%"]&.to_f,
      "min" => player["min"]&.to_i,
      "ga" => player["ga"]&.to_i
    }
  end

  def self.clean_name(raw)
    raw.to_s.gsub(/\s+#\d+/, '').strip
  end
end
