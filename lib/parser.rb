# lib/parser.rb
require 'nokogiri'

module Parser
  def self.extract_stats(doc)
    skaters = []
    goalies = []

    # 🔍 Scan all tables and classify by headers
    doc.css('table').each do |table|
      headers = table.css('thead tr th').map { |th| th.text.strip.downcase }
      warn "🧪 Table headers: #{headers.inspect}"

      rows = table.css('tbody tr')
      next if rows.empty?

      # Normalize headers for consistent keys
      normalized_headers = headers.map do |h|
        case h
        when '+/-' then 'plus_minus'
        when 'sv%' then 'sv_percent'
        else h
        end
      end

      rows.each do |row|
        cells = row.css('td').map { |td| td.text.strip }
        next if cells.empty?

        player = Hash[normalized_headers.zip(cells)]
        player['name'] = player.delete('player') || player.delete('name')

        if normalized_headers.include?('gaa') && normalized_headers.include?('sv_percent')
          goalie = normalize_goalie(player)
          goalies << goalie if goalie
          warn "🧪 Goalie detected: #{player['name']}"
        elsif normalized_headers.include?('gp') && normalized_headers.include?('pts')
          skater = normalize_skater(player)
          skaters << skater if skater
          warn "🧪 Skater detected: #{player['name']}"
        end
      end
    end

    { "skaters" => skaters, "goalies" => goalies }
  end

  def self.normalize_skater(player)
    return nil if player["gp"].nil? || player["gp"].strip.empty?

    {
      "name"       => clean_name(player["name"]),
      "gp"         => player["gp"]&.to_i,
      "g"          => player["g"]&.to_i,
      "a"          => player["a"]&.to_i,
      "pts"        => player["pts"]&.to_i,
      "plus_minus" => player["plus_minus"]&.to_i,
      "pim"        => player["pim"]&.to_i
    }
  end

  def self.normalize_goalie(player)
    {
      "name"       => clean_name(player["name"]),
      "gp"         => player["gp"]&.to_i,
      "w"          => player["w"]&.to_i,
      "l"          => player["l"]&.to_i,
      "otl"        => player["otl"]&.to_i,
      "gaa"        => player["gaa"]&.to_f,
      "sv_percent" => player["sv_percent"]&.to_f,
      "min"        => player["min"]&.to_i,
      "ga"         => player["ga"]&.to_i
    }
  end

  def self.clean_name(raw)
    raw.to_s.gsub(/\s+#\d+/, '').strip
  end
end
