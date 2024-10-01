def cpu_intensive
  puts "Pid: #{Process.pid}"
  x = 0
  1_000_000_000.times do |i|
    x += i
  end
end

fork

cpu_intensive
