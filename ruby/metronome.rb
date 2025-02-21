raise ArgumentError, "specify PERIOD" if ENV["PERIOD"].nil?

period = ENV["PERIOD"].to_i

class String
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def green
    colorize(32)
  end

  def blue
    colorize(34)
  end
end

def ascii(color)
  puts `clear`

  square = "
████████
██    ██
██    ██
████████
"

  case color
  when :green
    puts square.green
  when :blue
    puts square.blue
  end
end

loop do
  ascii(:green)
  sleep(period)
  ascii(:blue)
  sleep(period)
end
