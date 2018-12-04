# --- Day 3: No Matter How You Slice It ---
#
# The Elves managed to locate the chimney-squeeze prototype fabric for Santa's suit (thanks to
# someone who helpfully wrote its box IDs on the wall of the warehouse in the middle of the
# night).  Unfortunately, anomalies are still affecting them - nobody can even agree on how to cut
# the fabric.
#
# The whole piece of fabric they're working on is a very large square - at least 1000 inches on
# each side.
#
# Each Elf has made a claim about which area of fabric would be ideal for Santa's suit.  All
# claims have an ID and consist of a single rectangle with edges parallel to the edges of the
# fabric.  Each claim's rectangle is defined as follows:
#
#
# The number of inches between the left edge of the fabric and the left edge of the rectangle.
# The number of inches between the top edge of the fabric and the top edge of the rectangle.
# The width of the rectangle in inches.
# The height of the rectangle in inches.
#
# A claim like #123 @ 3,2: 5x4 means that claim ID 123 specifies a rectangle 3 inches from the
# left edge, 2 inches from the top edge, 5 inches wide, and 4 inches tall. Visually, it claims the
# square inches of fabric represented by # (and ignores the square inches of fabric represented by
# .) in the diagram below:
#
# ...........
# ...........
# ...#####...
# ...#####...
# ...#####...
# ...#####...
# ...........
# ...........
# ...........
#
# The problem is that many of the claims overlap, causing two or more claims to cover part of the
# same areas.  For example, consider the following claims:
#
# #1 @ 1,3: 4x4
# #2 @ 3,1: 4x4
# #3 @ 5,5: 2x2
#
# Visually, these claim the following areas:
#
# ........
# ...2222.
# ...2222.
# .11XX22.
# .11XX22.
# .111133.
# .111133.
# ........
#
# The four square inches marked with X are claimed by both 1 and 2. (Claim 3, while adjacent to
# the others, does not overlap either of them.)
#
# If the Elves all proceed with their own plans, none of them will have enough fabric. How many
# square inches of fabric are within two or more claims?
#

require_relative 'input'

day = __FILE__[/\d+/].to_i(10)
input = Input.for_day(day, 2018)

# puts "solving day #{day} from input:\n#{input}"

# claim = /^#(?<claim>\d+) @ (?<left>\d+),(?<top>\d+): (?<width>\d+)x(?<height>\d+)$/
line = "#1145 @ 787,84: 29x28"

class Claim
  RE = /^#(?<claim>\d+) @ (?<left>\d+),(?<top>\d+): (?<width>\d+)x(?<height>\d+)$/

  attr_accessor :id, :left, :top, :width, :height
  def initialize(string)
    md = RE.match(string)
    fail unless md
    @id     = md['claim'].to_i
    @left   = md['left'].to_i
    @top    = md['top'].to_i
    @width  = md['width'].to_i
    @height = md['height'].to_i
  end

  def to_s
    "\##{id} @ #{left},#{top}: #{width}x#{height}"
  end

  def columns
    self.left ... (self.left + self.width)
  end
  def rows
    self.top ... (self.top + self.height)
  end
end

claims = []
input.each_line(chomp: true).with_index do |line,i|
  puts i, line, Claim.new(line)
  claims << Claim.new(line)
end

wide = claims.map{|c| c.left + c.width - 1}.max
tall = claims.map{|c| c.top + c.height - 1}.max

cloth = Array.new(tall+1) {|row| Array.new(wide+1) { 0 } }

claims.each do |claim|
  claim.rows.each do |row|
    claim.columns.each do |col|
      cloth[row][col] += 1
    end
  end
end

disputed = cloth.flatten.count {|piece| piece > 1}

puts "Part 1: #{disputed}"

# --- Part Two ---
#
# Amidst the chaos, you notice that exactly one claim doesn't overlap by even a single square inch
# of fabric with any other claim. If you can somehow draw attention to it, maybe the Elves will be
# able to make Santa's suit after all!
#
# For example, in the claims above, only claim 3 is intact after all claims are made.
#
# What is the ID of the only claim that doesn't overlap?

winner = nil
claims.each do |claim|
  infringed = false
  claim.rows.each do |row|
    claim.columns.each do |col|
      infringed ||= cloth[row][col] > 1
    end
  end
  winner = claim unless infringed
end

puts "Part 2: #{winner}"
