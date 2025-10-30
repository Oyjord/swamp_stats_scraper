require "nokogiri"
require "open-uri"
require "json"

url = "https://echl.com/teams/greenville-swamp-rabbits"
doc = Nokogiri::HTML(URI.open(url))

tables = doc.css("table")

skaters = []
goalies = []

tables.each do |table|
  headers = table.css("thead th").map(&:text).map(&:strip)
  rows = table.css("tbody tr")

  if headers.include?("G") && headers.include?("A") && headers.include?("PTS")
    # Skater table
    rows.each do |row|
      cells = row.css("td").map(&:text).map(&:strip)
      next unless cells.size >= 7
      skaters << {
        name: cells[0],
        gp: cells[1].to_i,
        g: cells[2].to_i,
        a: cells[3].to_i,
        pts: cells[4].to_i,
        plus_minus: cells[5].to_i,
        pim: cells[6].to_i
      }
    end
  elsif headers.include?("GAA") && headers.include?("SV%")
    # Goalie table
    rows.each do |row|
      cells = row.css("td").map(&:text).map(&:strip)
      next unless cells.size >= 10
      goalies << {
        name: cells[0],
        gp: cells[1].to_i,
        w: cells[2].to_i,
        gaa: cells[3].to_f,
        sv_percent: cells[4].to_f,
        l: cells[5].to_i,
        otl: cells[6].to_i,
        min: cells[9].to_i,
        ga: cells[10].to_i
      }
    end
  end
end

combined = { skaters: skaters, goalies: goalies }
File.write("output/swamp_stats.json", JSON.pretty_generate(combined))
puts "✅ Saved #{skaters.size} skaters and #{goalies.size} goalies"
