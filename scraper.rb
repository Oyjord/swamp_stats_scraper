require "nokogiri"
require "open-uri"
require "json"

url = "https://echl.com/teams/greenville-swamp-rabbits"
doc = Nokogiri::HTML(URI.open(url))

def extract_skaters(doc, section_title)
  skaters = []
  section = doc.at("h2:contains('#{section_title}')")
  table = section&.next_element
  table&.css("tbody tr")&.each do |row|
    cells = row.css("td").map(&:text).map(&:strip)
    next unless cells.size >= 7
    skaters << {
      name: cells[0],
      gp: cells[1].to_i,
      g: cells[2].to_i,
      a: cells[3].to_i,
      pts: cells[4].to_i,
      plus_minus: cells[5].to_i,
      pim: cells[6].to_i,
      position: section_title == "Forwards" ? "F" : "D"
    }
  end
  skaters
end

def extract_goalies(doc)
  goalies = []
  section = doc.at("h2:contains('Goalies')")
  table = section&.next_element
  table&.css("tbody tr")&.each do |row|
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
  goalies
end

skaters = extract_skaters(doc, "Forwards") + extract_skaters(doc, "Defensemen")
goalies = extract_goalies(doc)

combined = { skaters: skaters, goalies: goalies }
File.write("output/swamp_stats.json", JSON.pretty_generate(combined))
puts "✅ Saved #{skaters.size} skaters and #{goalies.size} goalies"
