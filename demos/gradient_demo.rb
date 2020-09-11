require "io/console"
require_relative "../game/ansi"

GRADIENT = ".-=+*#@%".chars
WALL_GRADIENT = (
  GRADIENT.map { |c| ANSI.red(c) } +
  GRADIENT.reverse.map { |c| ANSI.black_on_red(c) } +
  [ANSI.black_on_red(" ")]
)

IO.console.raw do |io|
  height, width = io.winsize

  gradation_size = (height / WALL_GRADIENT.length).floor
  display_size = gradation_size * WALL_GRADIENT.length
  padding = height - display_size

  padding.times do
    io.write(" " * width + "\r\n")
  end

  display_size.times do |i|
    index = (i / gradation_size).floor
    char = WALL_GRADIENT.fetch(index)
    io.write(char * width + "\r\n")
  end

  io.getch
  io.write(ANSI.restore_terminal_state)
end
