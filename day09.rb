# --- Day 9: Marble Mania ---
#
# You talk to the Elves while you wait for your navigation system to initialize. To pass the time,
# they introduce you to their favorite marble game.
#
# The Elves play this game by taking turns arranging the marbles in a circle according to very
# particular rules. The marbles are numbered starting with 0 and increasing by 1 until every
# marble has a number.
#
# First, the marble numbered 0 is placed in the circle. At this point, while it contains only a
# single marble, it is still a circle: the marble is both clockwise from itself and
# counter-clockwise from itself. This marble is designated the current marble.
#
# Then, each Elf takes a turn placing the lowest-numbered remaining marble into the circle between
# the marbles that are 1 and 2 marbles clockwise of the current marble. (When the circle is large
# enough, this means that there is one marble between the marble that was just placed and the
# current marble.) The marble that was just placed then becomes the current marble.
#
# However, if the marble that is about to be placed has a number which is a multiple of 23,
# something entirely different happens. First, the current player keeps the marble they would have
# placed, adding it to their score. In addition, the marble 7 marbles counter-clockwise from the
# current marble is removed from the circle and also added to the current player's score. The
# marble located immediately clockwise of the marble that was removed becomes the new current
# marble.
#
# For example, suppose there are 9 players. After the marble with value 0 is placed in the middle,
# each player (shown in square brackets) takes a turn. The result of each of those turns would
# produce circles of marbles like this, where clockwise is to the right and the resulting current
# marble is in parentheses:
#
# [-] (0)
# [1]  0 (1)
# [2]  0 (2) 1
# [3]  0  2  1 (3)
# [4]  0 (4) 2  1  3
# [5]  0  4  2 (5) 1  3
# [6]  0  4  2  5  1 (6) 3
# [7]  0  4  2  5  1  6  3 (7)
# [8]  0 (8) 4  2  5  1  6  3  7
# [9]  0  8  4 (9) 2  5  1  6  3  7
# [1]  0  8  4  9  2(10) 5  1  6  3  7
# [2]  0  8  4  9  2 10  5(11) 1  6  3  7
# [3]  0  8  4  9  2 10  5 11  1(12) 6  3  7
# [4]  0  8  4  9  2 10  5 11  1 12  6(13) 3  7
# [5]  0  8  4  9  2 10  5 11  1 12  6 13  3(14) 7
# [6]  0  8  4  9  2 10  5 11  1 12  6 13  3 14  7(15)
# [7]  0(16) 8  4  9  2 10  5 11  1 12  6 13  3 14  7 15
# [8]  0 16  8(17) 4  9  2 10  5 11  1 12  6 13  3 14  7 15
# [9]  0 16  8 17  4(18) 9  2 10  5 11  1 12  6 13  3 14  7 15
# [1]  0 16  8 17  4 18  9(19) 2 10  5 11  1 12  6 13  3 14  7 15
# [2]  0 16  8 17  4 18  9 19  2(20)10  5 11  1 12  6 13  3 14  7 15
# [3]  0 16  8 17  4 18  9 19  2 20 10(21) 5 11  1 12  6 13  3 14  7 15
# [4]  0 16  8 17  4 18  9 19  2 20 10 21  5(22)11  1 12  6 13  3 14  7 15
# [5]  0 16  8 17  4 18(19) 2 20 10 21  5 22 11  1 12  6 13  3 14  7 15
# [6]  0 16  8 17  4 18 19  2(24)20 10 21  5 22 11  1 12  6 13  3 14  7 15
# [7]  0 16  8 17  4 18 19  2 24 20(25)10 21  5 22 11  1 12  6 13  3 14  7 15
#
# The goal is to be the player with the highest score after the last marble is used up. Assuming
# the example above ends after the marble numbered 25, the winning score is 23+9=32 (because
# player 5 kept marble 23 and removed marble 9, while no other player got any points in this very
# short example game).
#
# Here are a few more examples:
#
# 10 players; last marble is worth 1618 points: high score is 8317
# 13 players; last marble is worth 7999 points: high score is 146373
# 17 players; last marble is worth 1104 points: high score is 2764
# 21 players; last marble is worth 6111 points: high score is 54718
# 30 players; last marble is worth 5807 points: high score is 37305
#
# What is the winning Elf's score?

require_relative 'input'

day = __FILE__[/\d+/].to_i(10)
# input = Input.for_day(day, 2018)
# "416 players; last marble is worth 71617 points"

# player_count, marbles = 9, 25 if ARGV[0] == 'test'
[
  [9, 25, 32],
  [10, 1618, 8317],
  [13, 7999, 146373],
  [17, 1104, 2764],
  [21, 6111, 54718],
  [30, 5807, 37305],
  [416, 71617, nil],            # Part 1
  [416, 71617_00, nil],         # Part 2
].each do |player_count, marbles, expected|
  players = Array.new(player_count) { 0 }

  circle = [0]
  current_position = 0

  turn = 0

  (1..marbles).each do |marble|
    if (marble % 23).zero?
      # However, if the marble that is about to be placed has a number which is a multiple of 23,
      # something entirely different happens.

      # First, the current player keeps the marble they would have placed, adding it to their score.
      players[turn] += marble

      # In addition, the marble 7 marbles counter-clockwise from the current marble …
      7.times { current_position = (current_position - 1) % circle.size }
      # is removed from the circle and also added to the current player's score.
      players[turn] += circle.slice!(current_position,1).first

      # The marble located immediately clockwise of the marble that was removed becomes the new
      # current marble.
      current_position = current_position % circle.size

    else
      # Then, each Elf takes a turn placing the lowest-numbered remaining marble into the circle
      # between the marbles that are 1 and 2 marbles clockwise of the current marble.
      2.times { current_position = (current_position + 1) % circle.size }
      circle[current_position,0] = [marble]

      # (When the circle is large enough, this means that there is one marble between the marble
      # that was just placed and the current marble.) The marble that was just placed then becomes
      # the current marble.
    end

    turn = (turn + 1) % player_count
  end

  print "expected #{expected} for " if expected && expected != players.max

  puts "Part 1: Winning Elf's score", players.max
end
