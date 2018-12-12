# --- Day 10: The Stars Align ---
#
# It's no use; your navigation system simply isn't capable of providing walking directions in the
# arctic circle, and certainly not in 1018.
#
# The Elves suggest an alternative. In times like these, North Pole rescue operations will arrange
# points of light in the sky to guide missing Elves back to base. Unfortunately, the message is
# easy to miss: the points move slowly enough that it takes hours to align them, but have so much
# momentum that they only stay aligned for a second. If you blink at the wrong time, it might be
# hours before another message appears.
#
# You can see these points of light floating in the distance, and record their position in the sky
# and their velocity, the relative change in position per second (your puzzle input). The
# coordinates are all given from your perspective; given enough time, those positions and
# velocities will move the points into a cohesive message!
#
# Rather than wait, you decide to fast-forward the process and calculate what the points will
# eventually spell.
#
# For example, suppose you note the following points:
#
# position=< 9,  1> velocity=< 0,  2>
# position=< 7,  0> velocity=<-1,  0>
# position=< 3, -2> velocity=<-1,  1>
# position=< 6, 10> velocity=<-2, -1>
# position=< 2, -4> velocity=< 2,  2>
# position=<-6, 10> velocity=< 2, -2>
# position=< 1,  8> velocity=< 1, -1>
# position=< 1,  7> velocity=< 1,  0>
# position=<-3, 11> velocity=< 1, -2>
# position=< 7,  6> velocity=<-1, -1>
# position=<-2,  3> velocity=< 1,  0>
# position=<-4,  3> velocity=< 2,  0>
# position=<10, -3> velocity=<-1,  1>
# position=< 5, 11> velocity=< 1, -2>
# position=< 4,  7> velocity=< 0, -1>
# position=< 8, -2> velocity=< 0,  1>
# position=<15,  0> velocity=<-2,  0>
# position=< 1,  6> velocity=< 1,  0>
# position=< 8,  9> velocity=< 0, -1>
# position=< 3,  3> velocity=<-1,  1>
# position=< 0,  5> velocity=< 0, -1>
# position=<-2,  2> velocity=< 2,  0>
# position=< 5, -2> velocity=< 1,  2>
# position=< 1,  4> velocity=< 2,  1>
# position=<-2,  7> velocity=< 2, -2>
# position=< 3,  6> velocity=<-1, -1>
# position=< 5,  0> velocity=< 1,  0>
# position=<-6,  0> velocity=< 2,  0>
# position=< 5,  9> velocity=< 1, -2>
# position=<14,  7> velocity=<-2,  0>
# position=<-3,  6> velocity=< 2, -1>
#
# Each line represents one point. Positions are given as <X, Y> pairs: X represents how far left
# (negative) or right (positive) the point appears, while Y represents how far up (negative) or
# down (positive) the point appears.
#
# At 0 seconds, each point has the position given. Each second, each point's velocity is added to
# its position. So, a point with velocity <1, -2> is moving to the right, but is moving upward
# twice as quickly. If this point's initial position were <3, 9>, after 3 seconds, its position
# would become <6, 3>.
#
# Over time, the points listed above would move like this:
#
# Initially:
# ........#.............
# ................#.....
# .........#.#..#.......
# ......................
# #..........#.#.......#
# ...............#......
# ....#.................
# ..#.#....#............
# .......#..............
# ......#...............
# ...#...#.#...#........
# ....#..#..#.........#.
# .......#..............
# ...........#..#.......
# #...........#.........
# ...#.......#..........
#
# After 1 second:
# ......................
# ......................
# ..........#....#......
# ........#.....#.......
# ..#.........#......#..
# ......................
# ......#...............
# ....##.........#......
# ......#.#.............
# .....##.##..#.........
# ........#.#...........
# ........#...#.....#...
# ..#...........#.......
# ....#.....#.#.........
# ......................
# ......................
#
# After 2 seconds:
# ......................
# ......................
# ......................
# ..............#.......
# ....#..#...####..#....
# ......................
# ........#....#........
# ......#.#.............
# .......#...#..........
# .......#..#..#.#......
# ....#....#.#..........
# .....#...#...##.#.....
# ........#.............
# ......................
# ......................
# ......................
#
# After 3 seconds:
# ......................
# ......................
# ......................
# ......................
# ......#...#..###......
# ......#...#...#.......
# ......#...#...#.......
# ......#####...#.......
# ......#...#...#.......
# ......#...#...#.......
# ......#...#...#.......
# ......#...#..###......
# ......................
# ......................
# ......................
# ......................
#
# After 4 seconds:
# ......................
# ......................
# ......................
# ............#.........
# ........##...#.#......
# ......#.....#..#......
# .....#..##.##.#.......
# .......##.#....#......
# ...........#....#.....
# ..............#.......
# ....#......#...#......
# .....#.....##.........
# ...............#......
# ...............#......
# ......................
# ......................
#
# After 3 seconds, the message appeared briefly: HI. Of course, your message will be much longer
# and will take many more seconds to appear.
#
# What message will eventually appear in the sky?
#

require_relative 'input'

day = __FILE__[/\d+/].to_i(10)
input = Input.for_day(day, 2018)

puts "solving day #{day} from input"

RE=/position=< *(?<pos_x>-?[0-9]+), *(?<pos_y>-?[0-9]+)> velocity=< *(?<vel_x>-?[0-9]+), *(?<vel_y>-?[0-9]+)>/

class Point
  attr_accessor :pos_x, :pos_y, :dx, :dy
  def initialize(pos_x, pos_y, vel_x, vel_y)
    @pos_x, @pos_y, @dx, @dy = pos_x, pos_y, vel_x, vel_y
  end
  def move!(ticks=1)
    @pos_x += @dx * ticks
    @pos_y += @dy * ticks
  end
  def to_s
    "%5d,%5d"%[pos_x,pos_y]
  end
  def <=>(other)
    (self.pos_y <=> other.pos_y).nonzero? || (self.pos_x - other.pos_x)
  end
  include Comparable
  def shift!(x,y)
    @pos_x -= x
    @pos_y -= y
  end
  def is?(x,y)
    @pos_x == x && @pos_y == y
  end
end

points = []
input.each_line(chomp: true) do |line|
  points << Point.new(*RE.match(line).captures.map(&:to_i))
end

time = 0 + 10459
points.each {|p| p.move!(time) }

# puts points

# spread_x = points.map(&:pos_x).minmax.reverse.reduce(&:-).abs
# spread_y = points.map(&:pos_y).minmax.reverse.reduce(&:-).abs
# min_x = spread_x
# min_y = spread_y

# loop do
#   time += 1
#   points.each {|p| p.move! }
#   spread_x = points.map(&:pos_x).minmax.reverse.reduce(&:-).abs
#   spread_y = points.map(&:pos_y).minmax.reverse.reduce(&:-).abs
#   if spread_x < min_x || spread_y < min_y
#     if spread_x < min_x
#       min_x = spread_x
#     end
#     if spread_y < min_y
#       min_y = spread_y
#     end
#   else
#     break
#   end
# end

# puts points
# puts "  %5d,%5d\r"%[min_x,min_y]

20.times do
  sx = points.map(&:pos_x).min
  sy = points.map(&:pos_y).min
  points.each {|p| p.shift!(sx,sy) }

  # mx = points.map(&:pos_x).max
  # my = points.map(&:pos_y).max

  # points = points.sort

  # puts points
  puts `tput home`
  puts time
  (-10..25).each do |y|
    (-20..100).each do |x|
      if points.any?{|p|p.is?(x,y)}
        print '#'
      else
        print '.'
      end
    end
    puts "/"
  end
break
  sleep 0.5
  points.each {|p| p.move! }
  time += 1
end
