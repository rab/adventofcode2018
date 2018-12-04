# --- Day 4: Repose Record ---
#
# You've sneaked into another supply closet - this time, it's across from the prototype suit
# manufacturing lab. You need to sneak inside and fix the issues with the suit, but there's a
# guard stationed outside the lab, so this is as close as you can safely get.
#
# As you search the closet for anything that might help, you discover that you're not the first
# person to want to sneak in.  Covering the walls, someone has spent an hour starting every
# midnight for the past few months secretly observing this guard post!  They've been writing down
# the ID of the one guard on duty that night - the Elves seem to have decided that one guard was
# enough for the overnight shift - as well as when they fall asleep or wake up while at their post
# (your puzzle input).
#
# For example, consider the following records, which have already been organized into
# chronological order:
#
# [1518-11-01 00:00] Guard #10 begins shift
# [1518-11-01 00:05] falls asleep
# [1518-11-01 00:25] wakes up
# [1518-11-01 00:30] falls asleep
# [1518-11-01 00:55] wakes up
# [1518-11-01 23:58] Guard #99 begins shift
# [1518-11-02 00:40] falls asleep
# [1518-11-02 00:50] wakes up
# [1518-11-03 00:05] Guard #10 begins shift
# [1518-11-03 00:24] falls asleep
# [1518-11-03 00:29] wakes up
# [1518-11-04 00:02] Guard #99 begins shift
# [1518-11-04 00:36] falls asleep
# [1518-11-04 00:46] wakes up
# [1518-11-05 00:03] Guard #99 begins shift
# [1518-11-05 00:45] falls asleep
# [1518-11-05 00:55] wakes up
#
# Timestamps are written using year-month-day hour:minute format. The guard falling asleep or
# waking up is always the one whose shift most recently started. Because all asleep/awake times
# are during the midnight hour (00:00 - 00:59), only the minute portion (00 - 59) is relevant for
# those events.
#
# Visually, these records show that the guards are asleep at these times:
#
# Date   ID   Minute
#             000000000011111111112222222222333333333344444444445555555555
#             012345678901234567890123456789012345678901234567890123456789
# 11-01  #10  .....####################.....#########################.....
# 11-02  #99  ........................................##########..........
# 11-03  #10  ........................#####...............................
# 11-04  #99  ....................................##########..............
# 11-05  #99  .............................................##########.....
#
# The columns are Date, which shows the month-day portion of the relevant day; ID, which shows the
# guard on duty that day; and Minute, which shows the minutes during which the guard was asleep
# within the midnight hour.  (The Minute column's header shows the minute's ten's digit in the
# first row and the one's digit in the second row.) Awake is shown as ., and asleep is shown as #.
#
# Note that guards count as asleep on the minute they fall asleep, and they count as awake on the
# minute they wake up. For example, because Guard #10 wakes up at 00:25 on 1518-11-01, minute 25
# is marked as awake.
#
# If you can figure out the guard most likely to be asleep at a specific time, you might be able
# to trick that guard into working tonight so you can have the best chance of sneaking in.  You
# have two strategies for choosing the best guard/minute combination.
#
# Strategy 1: Find the guard that has the most minutes asleep. What minute does that guard spend
# asleep the most?
#
# In the example above, Guard #10 spent the most minutes asleep, a total of 50 minutes (20+25+5),
# while Guard #99 only slept for a total of 30 minutes (10+10+10). Guard #10 was asleep most
# during minute 24 (on two days, whereas any other minute the guard was asleep was only seen on
# one day).
#
# While this example listed the entries in chronological order, your entries are in the order you
# found them. You'll need to organize them before they can be analyzed.
#
# What is the ID of the guard you chose multiplied by the minute you chose? (In the above example,
# the answer would be 10 * 24 = 240.)
#

require_relative 'input'

day = __FILE__[/\d+/].to_i(10)
input = Input.for_day(day, 2018)

# puts "solving day #{day} from input:\n#{input}"

require 'time'

class Event
  attr_accessor :guard, :timestamp, :type
  def initialize(line)
    @timestamp = Time.parse(line[1..16])
    @type = case line[19..-1]
            when /Guard #(\d+) begins shift/
              @guard = $1.to_i
              :shift
            when /falls asleep/
              :asleep
            when /wakes up/
              :awake
            else
              fail line
            end
  end

  def <=>(other)
    self.timestamp <=> other.timestamp
  end

  def to_s
    str = "[#{self.timestamp.strftime('%Y-%m-%d %H:%M')}] " <<
          case self.type
          when :shift
            "Guard \##{self.guard} begins shift"
          when :asleep
            "falls asleep"
          when :awake
            "wakes up"
          else
            fail "crap"
          end
  end
end

events = []
input.each_line(chomp: true) do |line|
  events << Event.new(line)
end

events.sort!
# puts events

class Guard
  attr_accessor :id, :time_asleep

  def initialize(id)
    @id = id
    @events = []
    @state = :awake
    @time_asleep = 0
    @fell_asleep_at = nil
    @sleep_map = Array.new(60) { 0 }
  end

  def most_likely_asleep
    @sleep_map.index(sleepiest_minute)
  end

  def sleepiest_minute
    @sleep_map.max
  end

  def <<(event)
    case event.type
    when :asleep
      fail "inception? falls asleep when asleep" unless @state == :awake
      @fell_asleep_at = event.timestamp.min
      @state = :asleep
    when :awake
      fail "inception? wakes up when awake" unless @state == :asleep
      (@fell_asleep_at ... event.timestamp.min).each do |minute|
        @sleep_map[minute] += 1
      end
      @time_asleep += event.timestamp.min - @fell_asleep_at
      @fell_asleep_at = nil
      @state = :awake
    when :shift
      fail "Guard #{self.id} got #{event}" unless event.guard == self.id
      @state = :awake
      @fell_asleep_at = nil
    end
    @events << event
  end

  def to_s
    "Guard \#%4d: %4d %s"%[self.id, @time_asleep, @sleep_map.map {|m| m.zero? ? '.' : '#'}.join]
  end
end

guards = Hash.new {|h,k| h[k] = Guard.new(k) }

guard = nil
events.each do |event|
  if event.type == :shift
    guard = guards[event.guard]
  end
  guard << event
end

# puts guards.values
# puts

sleepy = guards.values.max_by(&:time_asleep)

puts sleepy
puts sleepy.most_likely_asleep
puts "Strategy 1: #{sleepy.id * sleepy.most_likely_asleep}"

# --- Part Two ---
#
# Strategy 2: Of all guards, which guard is most frequently asleep on the same minute?
#
# In the example above, Guard #99 spent minute 45 asleep more than any other guard or minute -
# three times in total. (In all other cases, any guard spent any minute asleep at most twice.)
#
# What is the ID of the guard you chose multiplied by the minute you chose? (In the above example,
# the answer would be 99 * 45 = 4455.)

micro = guards.values.max_by(&:sleepiest_minute)
puts micro
puts micro.sleepiest_minute
puts "Strategy 2: #{micro.id * micro.most_likely_asleep}"
