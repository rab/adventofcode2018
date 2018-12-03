# To simplify starting a new day on the Advent of Code challenge.
#
# Prerequisite: the presence of the ./.session file containing the "session=19827364918273..."
#   value for the cookie.
#
# Returns the cached input or retrieves and caches the indicated day's input.
#
# Note that some days may not have an input file if the input was specified in the description.

require 'date'
require 'uri'
require 'net/https'

module Input
  extend self
  def for_day(day, year=Date.today.year)
    cache_file = 'day%02d_input.txt'%[day]
    if File.exist? cache_file
      File.read(cache_file)
    else
      uri = URI('https://adventofcode.com/%d/day/%s/input'%[year, day.to_s])
      req = Net::HTTP::Get.new(uri)
      req['Cookie'] = File.read('./.session') if File.exist?('./.session')
      res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) {|http|
        http.request(req)
      }
      res.body.tap {|contents| File.write(cache_file, contents) }
    end
  end
end
