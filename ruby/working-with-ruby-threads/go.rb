# TODO:
# * Process.fork
# * Celluloid
# * googl for it?

# An interesting task came out of my head, it's a follow up for Working With Ruby Threads book which I read recently: [LINK]
# We do have an array which is called `numbers`` and we do have a jobs which are applied to each number of this array. My goal is to make all numbers to be processed as fast as possible and write each calculation result to the file

numbers = (1..1000).to_a

require 'benchmark'

# There are two types of jobs:
#   * sync_job - it's a cpu-bound (like factorial or fibonacci number calculation)
#   * async_job - it's I/O-bound but I'm using sleep here for faster emulation

def sync_job(x)
  x == 1 ? x : x * sync_job(x - 1)
end

def async_job(x)
  value = rand(0.01..0.05)
  sleep(value)
  value
end

def job(sync, x)
  sync ? sync_job(x) : async_job(x)
end

# Write to file

def _write_to_file(file, argument, result)
  file.write("#{argument} => #{result}\n")
end

# A sequential approach, using `each` to sequentially run all the calculations

def sequential(ary, sync, filename)
  file = File.new(filename, 'w')

  ary.each do |a|
    result = job(sync, a)
    _write_to_file(file, a, result)
  end
end

# A concurrent (not parallel) approach using ruby mutexes.
# We are starting a new thread for each number, and running a job inside
# Once mutex has been finished, we are focusing GIL on I/O bound writing to the file opeartion (semaphore.synchronize)
# This case, it's guaranteed that only one thread will write to the file at certain moment of the time

def mutex(ary, sync, filename)
  file = File.new(filename, 'w')
  semaphore = Mutex.new

  ary.map do |a|
    Thread.new do
      result = job(sync, a)

      semaphore.synchronize do
        _write_to_file(file, a, result)
      end
    end
  end.each(&:join)
end

# Ractor (Ruby actor) is a truly parallel thing in Ruby. So, if you have more than one core in your CPU, expect CPU-bound things to be X times faster!
# Let me explain you the implementation though.
# There is a `writer` ractor which is all about writing to the file. Why do we need it? We want to be sure that there couldn't be two simultaneous writings to the file simultaneously. It runs an infinite loop inside. Once it receives something (Ractor.receive) it starts writing and it's blocked during that time. Once writer finished it's duty, loop just circles and ractor starts to wait for the next argument. NOTE: since we don't have a `take` on it, ruby program will end if this ractor ends its implementation.
# And, the working horse here: an array of ractors for each number. Any of these will be implemented on all cores of the computer.
#

def ractor(ary, sync, filename)
  file = File.new(filename, 'w')

  writer = Ractor.new file do |file|
    loop do
      argument, result = Ractor.receive
      _write_to_file(file, argument, result)
    end
  end

  ary.map do |a|
    Ractor.new a, sync, writer do |a, sync, writer|
      result = job(sync, a)
      writer.send [a, result]
    end
  end.each(&:take)
end

# Let's start it sync!
# What do we have here?
# TODO how to read ruby benchmarks?
# sequential:   0.153535   0.002879   0.156414 (  0.156433)
# mutex:        0.371738   0.268052   0.639790 (  0.678934)
# ractor:       0.391240   0.121033   0.512273 (  0.202072)

the_sync = false

Benchmark.bm do |bm|
  bm.report('sequential: ') { sequential(numbers, the_sync, 'sequential.txt') }
  bm.report('mutex:      ') { mutex(numbers, the_sync, 'mutex.txt') }
  bm.report('ractor:     ') { ractor(numbers, the_sync, 'ractor.txt') }
end
