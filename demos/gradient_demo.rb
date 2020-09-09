require "io/console"
require_relative "game/ansi"

GRADIENT = ".-=+*#@%"

IO.console.raw do |io|
  height, width = io.winsize

  gradation_size = (height / GRADIENT.length).floor

  height.times do |i|
    index = (i / gradation_size).floor
    char = GRADIENT[index]
    io.write(char * width + "\r\n")
  end

  io.getch
  io.write(ANSI.restore_terminal_state)
end
