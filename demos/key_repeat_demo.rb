#!/usr/bin/env ruby

require "io/console"

count = 0

start = nil
finish = nil

IO.console.raw do |io|
  io.getch
  start = Time.now.to_f
  100.times do
    io.getch
  end
  finish = Time.now.to_f
end

puts "1000 #getch in #{finish - start}"
