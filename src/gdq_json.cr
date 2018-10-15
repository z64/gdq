require "json"

struct Run
  include JSON::Serializable

  module TimeConverter
    def self.from_json(parser : JSON::PullParser)
      time = Time.new(parser)
      time.in(Time::Location::UTC)
    end
  end

  module SpanConverter
    def self.from_json(parser : JSON::PullParser)
      raw = parser.read_string
      hours, minutes, seconds = raw.split(':').map(&.to_i)
      Time::Span.new(hours: hours, minutes: minutes, seconds: seconds)
    end
  end

  getter runners : Array(String)
  getter game : String
  getter platform : String?
  getter category : String
  getter host : String?

  @[JSON::Field(converter: Run::TimeConverter)]
  getter time : Time

  @[JSON::Field(converter: Run::SpanConverter)]
  getter length : Time::Span

  @[JSON::Field(converter: Run::SpanConverter)]
  getter setup_length : Time::Span
end

File.open("data/runs.json") do |file|
  runs = Array(Run).from_json(file, "runs")

  location = Time::Location.load("US/Eastern")
  report = String.build do |str|
    runs.each do |run|
      str << "[Game]    " << run.game << " (" << (run.platform || "Unknown platform") << ", " << run.category << ")\n"
      str << "[Runners] " << run.runners.join(", ") << '\n'
      str << "[Host]    " << (run.host || "Unknown host") << '\n'
      time = run.time.in(location) + 1.hour
      time = time.to_s("%a %r")
      str << "[Time]    " << time << "\n"
      str << "[Length]  " << run.length << " (" << run.setup_length << " setup)\n"
      str << "......... \n"
    end
  end

  puts report
end
