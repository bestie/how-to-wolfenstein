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
    end
  end

  private

  def get_input
    @input_buffer << io.getch
  end

  def update_game_state
  end

  def render_frame
    map.rows.each do |row|
      io.write(row.join + "\r\n")
    end
    io.write(27.chr + "[" + map.rows.length.to_s + "A")
  end

  def ctrl_c?
    @input_buffer.last == ?\C-c
  end
end
