hash = {}

1_000_000.times do |i|
  hash[i] = 'foo'
end

puts "Hash contains #{hash.keys.count} keys"

def show_memory_usage(whoami)
  pid = Process.pid

  mem = `pmap #{pid}`

  puts "memory usage for #{whoami} pid: #{pid} is #{mem.lines.to_a.last}"
end

puts "let's test"

if fork
  show_memory_usage("parent")
else
  puts "going into child"

  3_000_000.times do |i|
    hash[i + 1_000_000] = 'bar'
  end

  show_memory_usage("child")
end
