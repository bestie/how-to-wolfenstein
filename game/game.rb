Thread.abort_on_exception = true

class Game
  def initialize(io:, map:, player:, renderer:)
    @io = io
    @map = map
    @player = player
    @renderer = renderer

    @over = false
    @input_buffer = []
    @player.position = map.player_start_position
    @field_of_view = π / 4.0

    @frame_count = 0
    @window_timer = nil
  end

  attr_reader :io, :map, :player, :renderer, :field_of_view
  private     :io, :map, :player, :renderer, :field_of_view

  def start
    io.write(ANSI.save_terminal_state)
    io.write(ANSI.hide_cursor)
    @canvas_size = io.winsize

    start_input_thread
    render_frame
    until @over do
      render_frame_measured
    end

  rescue => e
    $log.puts(e.inspect)
    $log.puts(e.backtrace)
  ensure
    io.write(ANSI.restore_terminal_state)
    io.write(ANSI.unhide_cursor)
  end

  def stop
    @over = true
    io.write("\r\n")
  end

  private

  def start_input_thread
    @input_thread ||= Thread.new do
      until @over
        get_input
        update_game_state
      end
    end
  end

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

  def render_frame_measured
    @window_timer ||= Time.now.to_f
    @frame_count += 1

    render_frame

    sample_window = Time.now.to_f - @window_timer
    if sample_window > 1.0 && @frame_count > 0
      frame_rate = @frame_count / sample_window
      $log.puts "Frame rate: #{frame_rate.round(2)}"
      @frame_count = 0
      @window_timer = nil
    end
  end

  def render_frame
    io.write(ANSI.cursor_top_left)

    output_buffer = []

    map_hud = map
      .overlay_player(@player.position, @player.angle)
      .rows

    scene = renderer.call(
      map: map,
      field_of_view: field_of_view,
      position: player.position,
      angle: player.angle,
      canvas_width: canvas_width,
      canvas_height: canvas_height,
    )

    scene.each { |line_chars| output_buffer << line_chars }

    map_hud.each_with_index do |map_line, i|
      output_buffer[i] = map_line + output_buffer[i].drop(map_line.length)
    end

    if map.goal?(player.position)
      write_buffer(win_frame)
      sleep(2)
      stop
    else
      write_buffer(output_buffer)
    end
  end

  def write_buffer(buffer)
    io.write(buffer.map(&:join).join("\r\n"))
  end

  def win_frame
    canvas_height.times.map { ["\u{1F645} "] * (canvas_width / 2) }
  end

  def canvas_width
    @canvas_size[1]
  end

  def canvas_height
    @canvas_size[0]
  end
end
