# --- Day 6: Chronal Coordinates ---
#
# The device on your wrist beeps several times, and once again you feel like you're falling.
#
# "Situation critical," the device announces. "Destination indeterminate. Chronal interference
# detected. Please specify new target coordinates."
#
# The device then produces a list of coordinates (your puzzle input). Are they places it thinks
# are safe or dangerous? It recommends you check manual page 729. The Elves did not give you a
# manual.
#
# If they're dangerous, maybe you can minimize the danger by finding the coordinate that gives the
# largest distance from the other points.
#
# Using only the Manhattan distance, determine the area around each coordinate by counting the
# number of integer X,Y locations that are closest to that coordinate (and aren't tied in distance
# to any other coordinate).
#
# Your goal is to find the size of the largest area that isn't infinite. For example, consider the
# following list of coordinates:
#
# 1, 1
# 1, 6
# 8, 3
# 3, 4
# 5, 5
# 8, 9
#
# If we name these coordinates A through F, we can draw them on a grid, putting 0,0 at the top left:
#
# ..........
# .A........
# ..........
# ........C.
# ...D......
# .....E....
# .B........
# ..........
# ..........
# ........F.
#
# This view is partial - the actual grid extends infinitely in all directions.  Using the
# Manhattan distance, each location's closest coordinate can be determined, shown here in
# lowercase:
#
# aaaaa.cccc
# aAaaa.cccc
# aaaddecccc
# aadddeccCc
# ..dDdeeccc
# bb.deEeecc
# bBb.eeee..
# bbb.eeefff
# bbb.eeffff
# bbb.ffffFf
#
# Locations shown as . are equally far from two or more coordinates, and so they don't count as
# being closest to any.
#
# In this example, the areas of coordinates A, B, C, and F are infinite - while not shown here,
# their areas extend forever outside the visible grid. However, the areas of coordinates D and E
# are finite: D is closest to 9 locations, and E is closest to 17 (both including the coordinate's
# location itself).  Therefore, in this example, the size of the largest area is 17.
#
# What is the size of the largest area that isn't infinite?
#

require_relative 'input'

day = __FILE__[/\d+/].to_i(10)
input = Input.for_day(day, 2018)

input = "1,1\n1,6\n8,3\n3,4\n5,5\n8,9\n" if ARGV[0] == 'test'

puts "solving day #{day} from input"

class Point
  NAMES = (('a'..'z').to_a + ('A'..'Z').to_a).freeze
  @@next = 0

  attr_accessor :x, :y, :closest_to
  attr_reader :name

  def initialize(x, y, anon: false)
    @x, @y = x, y
    @closest_to = 0
    unless anon
      @name = NAMES[@@next]
      @@next += 1
    end
  end

  def +(other)
    self.class.new(self.x + other.x, self.y + other.y, anon: true)
  end

  def -(other)
    self.class.new(self.x - other.x, self.y - other.y, anon: true)
  end

  def ==(other)
    self.x == other.x && self.y == other.y
  end

  def manhattan(other)
    (self.x - other.x).abs + (self.y - other.y).abs
  end

  def to_s
    "#{@name || '?'}: #{@x}, #{@y} (#{@closest_to})"
  end
end

# help from: https://en.wikipedia.org/wiki/Graham_scan

# First, define

# Three points are a counter-clockwise turn if ccw > 0, clockwise if
# ccw < 0, and collinear if ccw = 0 because ccw is a determinant that
# gives twice the signed area of the triangle formed by p1, p2 and p3.
def ccw(p1, p2, p3)
  (p2.x - p1.x)*(p3.y - p1.y) - (p2.y - p1.y)*(p3.x - p1.x)
end

# Then let the result be stored in the stack.

# let N be number of points
# let points[N] be the array of points
points = []
input.each_line(chomp: true) do |line|
  x, y = line.split(/, */).map(&:to_i)
  points << Point.new(x, y)
end
n = points.size

max_x, max_y = points.map(&:x).max, points.map(&:y).max
puts points, n, "\n"
puts "Grid: #{max_x} x #{max_y}"

# swap points[0] with the point with the lowest y-coordinate
min_y = points.map(&:y).min
puts "min_y = #{min_y}"
candidates = points.select {|p| p.y == min_y}
puts "candidates:", candidates
candidate = if candidates.size == 1
              candidates.first
            else
              candidates.min_by(&:x)
            end
puts "candidate:", candidate
c_i = (0...n).each {|i| break i if points[i] == candidate }
puts "c_i: #{c_i}"
points[0], points[c_i] = points[c_i], points[0] unless c_i.zero?

puts "\nunsorted:", points

# sort points by polar angle with points[0]
points[1..-1] = points[1..-1].sort {|p2, p3| -ccw(points[0], p2, p3) }
puts "\nsorted:", points
# fail "still not sorted"

stack = []                      # let stack = empty_stack()
stack << points[0]              # push points[0] to stack
stack << points[1]              # push points[1] to stack

# for i = 2 to N-1:
(2...n).each do |i|
  #   while count stack >= 2 and ccw(next_to_top(stack), top(stack), points[i]) <= 0:
  #       pop stack
  while stack.size >= 2 && ccw(stack[-2], stack[-1], points[i]) <= 0
    stack.pop
  end

  #   push points[i] to stack
  stack << points[i]
  # end
end

puts "\nHull: #{stack.size}", stack

dot = Point.new(0,0, anon: true)
(0..max_y).each do |y|
  dot.y = y
  (0..max_x).each do |x|
    dot.x = x
    distance = Hash.new {|h,d| h[d] = []}
    points.each do |point|
      distance[dot.manhattan(point)] << point
    end
    min = distance.keys.min
    if distance[min].count == 1
      close = distance[min].first
      close.closest_to += 1
      print close.name
    else
      print '.'
    end
  end
  puts
end

puts "closest:", points.sort_by(&:closest_to).reverse.delete_if {|p| stack.include?(p)}.first

# --- Part Two ---
#
# On the other hand, if the coordinates are safe, maybe the best you can do is try to find a
# region near as many coordinates as possible.
#
# For example, suppose you want the sum of the Manhattan distance to all of the coordinates to be
# less than 32. For each location, add up the distances to all of the given coordinates; if the
# total of those distances is less than 32, that location is within the desired region. Using the
# same coordinates as above, the resulting region looks like this:

# ..........
# .A........
# ..........
# ...###..C.
# ..#D###...
# ..###E#...
# .B.###....
# ..........
# ..........
# ........F.
#
# In particular, consider the highlighted location 4,3 located at the top middle of the
# region. Its calculation is as follows, where abs() is the absolute value function:
#
# Distance to coordinate A: abs(4-1) + abs(3-1) =  5
# Distance to coordinate B: abs(4-1) + abs(3-6) =  6
# Distance to coordinate C: abs(4-8) + abs(3-3) =  4
# Distance to coordinate D: abs(4-3) + abs(3-4) =  2
# Distance to coordinate E: abs(4-5) + abs(3-5) =  3
# Distance to coordinate F: abs(4-8) + abs(3-9) = 10
#
# Total distance: 5 + 6 + 4 + 2 + 3 + 10 = 30
#
# Because the total distance to all coordinates (30) is less than 32, the location is within the
# region.
#
# This region, which also includes coordinates D and E, has a total size of 16.
#
# Your actual region will need to be much larger than this example, though, instead including all
# locations with a total distance of less than 10000.
#
# What is the size of the region containing all locations which have a total distance to all given
# coordinates of less than 10000?

dot = Point.new(0,0, anon: true)
limit = 10_000
region_contains = 0
(0..max_y).each do |y|
  dot.y = y
  (0..max_x).each do |x|
    dot.x = x
    total_distance = 0
    points.each do |point|
      total_distance += dot.manhattan(point)
    end
    if total_distance < limit
      region_contains += 1
      print '#'
    else
      print '•'
    end
  end
  puts
end

puts "safe region: #{region_contains}"
