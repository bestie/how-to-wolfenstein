class Game
  LEFT_ARROW = [27.chr, "[", "D"]
  RIGHT_ARROW = [27.chr, "[", "C"]

  def initialize(io:, map:, player:, log:)
    @io = io
    @map = map
    @player = player
    @log = log

    @input_buffer = []
    @player.position = map.player_start_position
  end

  attr_reader :io, :map, :player, :log
  private     :io, :map, :player, :log

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
    case @input_buffer.last
    when "w"
      player.walk_forward
    when "a"
      player.strafe_left
    when "s"
      player.walk_back
    when "d"
      player.strafe_right
    end

    case @input_buffer.last(3)
    when LEFT_ARROW
      player.turn_left
    when RIGHT_ARROW
      player.turn_right
    end
  end

  def render_frame
    output_buffer = []
    output_buffer <<  "Input buffer: #{@input_buffer.last(10)}"
    output_buffer <<  "Player position: #{@player.position.to_a}"
    output_buffer <<  "Player angle: #{@player.angle * π / 180.0}"

    map
      .overlay_player(@player.position)
      .rows.each do |row|
        output_buffer << (row.join)
      end

    output_buffer.each { |line| io.write(line + "\r\n") }
    io.write(27.chr + "[" + output_buffer.length.to_s + "A")
  end

  def ctrl_c?
    @input_buffer.last == ?\C-c
  end
end
