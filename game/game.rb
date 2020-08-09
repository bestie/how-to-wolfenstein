class Game
  def initialize(io:, map:, log:)
    @io = io
    @map = map
    @log = log

    @input_buffer = []
  end

  attr_reader :io, :map, :log
  private     :io, :map, :log

  def start
    render_frame

    until ctrl_c? do
      get_input
      update_game_state
      render_frame
    end
  end

  private

  def get_input
    @input_buffer << io.getch
  end

  def update_game_state
  end

  def render_frame
    output_buffer = []
    output_buffer <<  "Input buffer: #{@input_buffer.last(10)}"
    map.rows.each do |row|
      output_buffer << (row.join)
    end

    output_buffer.each { |line| io.write(line + "\r\n") }
    io.write(27.chr + "[" + output_buffer.length.to_s + "A")
  end

  def ctrl_c?
    @input_buffer.last == ?\C-c
  end
end
