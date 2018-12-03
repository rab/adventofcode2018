# To simplify starting a new day on the Advent of Code challenge.
#
# Usage: ruby day_prep.rb [day]
#
# Prerequisite: the presence of the ./.session file containing the "session=19827364918273..."
#   value for the cookie.
#
# When: Runs anytime during the day (Eastern time) to get the challenge from the current day or
#   from a single past date by supplying the day number as an argument.
#
# The "Part Two" will typically have to be retrieved manually.
#
require 'date'
require 'uri'
require 'net/https'
require 'nokogiri'
require_relative 'input'

day = ARGV[0].to_i.nonzero? || Date.today.day
year = Date.today.year
filename = 'day%02d.rb'%[day]
unless File.exist? filename
  if File.exist?(html = filename.sub(/\.rb\z/,'.html'))
    doc = Nokogiri::HTML File.read(html)
  else
    uri = URI('https://adventofcode.com/%d/day/%d'%[year, day])
    req = Net::HTTP::Get.new(uri)
    req['Cookie'] = File.read('./.session') if File.exist?('./.session')
    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) {|http|
      http.request(req)
    }
    doc = Nokogiri::HTML res.body.tap {|contents| File.write(html, contents) }
  end

  File.open(filename, 'w') do |f|
    doc.css('article.day-desc').children.each do |node|
      f.puts node.text.gsub(/^/,'# ')
    end
    f.puts
    f.write File.read('day_template.rb')
  end

  # Might as well get the input, too
  Input.for_day(day, year)
end
