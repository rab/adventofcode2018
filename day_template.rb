require_relative 'input'

day = __FILE__[/\d+/].to_i(10)
input = Input.for_day(day, 2017)

puts "solving day #{day} from input:\n#{input}"
