class DemoIOAdapter
  def initialize(io, char_stream, winsize: [40, 120], delay: 1.0)
    @io = io
    @char_stream = char_stream
    @delay = delay
    @cursor = 0
    @winsize = winsize
  end

  attr_reader :winsize

  def write(s)
    @io.write(s)
  end

  def getch(*args)
    char = @char_stream[@cursor]
    unless ["\e", "["].include?(char)
      sleep(@delay)
    end
    @cursor += 1
    char || ANSI.ctrl_c
  end
end
