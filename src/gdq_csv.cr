require "json"
require "csv"

class RowValues
  property time : String = ""
  property game : String = ""
  property category : String = ""
  property runners : String = ""
  property length : String = ""
end

File.open("data/runs.csv", "w") do |csv_file|
  builder = CSV::Builder.new(csv_file)
  values = RowValues.new
  location = Time::Location.load("US/Eastern")

  File.open("data/runs.json", "r") do |json_file|
    parser = JSON::PullParser.new(json_file)
    parser.on_key("runs") do
      index = 0
      parser.read_array do
        parser.read_object do |key|
          case key
          when "game"
            values.game = parser.read_string
          when "category"
            values.category = parser.read_string
          when "time"
            time = Time.new(parser).in(location) + 1.hour
            values.time = time.to_s("%a %r")
          when "runners"
            values.runners = Array(String).new(parser).join(", ")
          when "length"
            values.length = parser.read_string
          else
            parser.skip
          end
        end
        builder.row(index, values.time, values.game, values.category, values.runners, values.length)
        index += 1
      end
    end
  end
end
