class DemoIOAdapter
  def initialize(io, char_stream, delay: 1.0)
    @io = io
    @char_stream = char_stream
    @delay = delay
    @cursor = 0
  end

  def write(s)
    @io.write(s)
  end

  def getch(*args)
    char = @char_stream[@cursor]
    sleep(@delay)
    @cursor += 1
    char || ANSI.ctrl_c
  end

  def winsize
    [80, 40]
  end
end
