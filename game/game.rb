class Game
  def initialize(io:, map:, player:, log:)
    @io = io
    @map = map
    @player = player
    @log = log

    @over = false
    @input_buffer = []
    @player.position = map.player_start_position
  end

  attr_reader :io, :map, :player, :log
  private     :io, :map, :player, :log

  def start
    @canvas_size = io.winsize
    render_frame

    io.write(ANSI.save_terminal_state)
    io.write(ANSI.cursor_top_left)

    until @over do
      get_input
      update_game_state
      render_frame
    end

    io.write(ANSI.restore_terminal_state)
  end

  def stop
    @over = true
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
    when ANSI.ctrl_c
      stop
    end

    case @input_buffer.last(3).join
    when ANSI.left_arrow
      player.turn_left
    when ANSI.right_arrow
      player.turn_right
    end
  end

  def render_frame
    io.write(ANSI.cursor_top_left)

    output_buffer = []
    output_buffer <<  "Input buffer: #{@input_buffer.last(10)}"
    output_buffer <<  "Player position: #{@player.position.to_a}"
    output_buffer <<  "Player angle: #{@player.angle * π / 180.0}"

    map
      .overlay_player(@player.position, @player.angle)
      .rows.each do |row|
        output_buffer << (row.join)
      end

    if map.goal?(player.position)
      output_buffer = win_frame
      output_buffer.each { |line| io.write(line + "\r\n") }
      sleep(2)
    else
      output_buffer.each { |line| io.write(line + "\r\n") }
    end
  end

  def win_frame
    ["\u{1F645} " * canvas_width] * canvas_height
  end

  def canvas_width
    @canvas_size[0]
  end

  def canvas_height
    @canvas_size[1]
  end
end
