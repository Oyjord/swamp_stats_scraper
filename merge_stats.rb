
require "json"

skaters = JSON.parse(File.read("output/swamp_skaters.json"))
goalies = JSON.parse(File.read("output/swamp_goalies.json"))

merged = {
  skaters: skaters,
  goalies: goalies
}

File.write("output/swamp_stats.json", JSON.pretty_generate(merged))
puts "✅ Merged stats written to output/swamp_stats.json"
