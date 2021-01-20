Thread.abort_on_exception = true

class Game
  def initialize(io:, maps:, player:, renderer:)
    @io = io
    @maps = maps
    @player = player
    @renderer = renderer

    @over = false
    @current_map_index = 0
    @input_buffer = []
    @field_of_view = π / 4.0
    @input_thread = nil
    reset_map

    @frame_count = 0
    @window_timer = nil
    @show_map = true
    @current_frame_rate = 0
  end

  attr_reader :io, :player, :renderer, :field_of_view
  private     :io, :player, :renderer, :field_of_view

  def start
    start_input_thread

    io.write(ANSI.save_terminal_state + ANSI.hide_cursor)
    @canvas_size = io.winsize

    until @over do
      render_frame_measured
    end

  rescue => e
    $log.puts(e.inspect)
    $log.puts(e.backtrace)
  ensure
    stop
    io.write(ANSI.restore_terminal_state + ANSI.unhide_cursor)
  end

  def stop
    @over = true
    @input_thread && @input_thread.terminate
  end

  def over?
    !!@over
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
    char = @input_buffer.last

    case char
    when "w"
      player.walk_forward { |pos| map.in_bounds?(pos) }
    when "a"
      player.strafe_left { |pos| map.in_bounds?(pos) }
    when "s"
      player.walk_back { |pos| map.in_bounds?(pos) }
    when "d"
      player.strafe_right { |pos| map.in_bounds?(pos) }
    when "m"
      @show_map = !@show_map
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
    $total_frames += 1

    render_frame

    sample_window = Time.now.to_f - @window_timer
    if sample_window > 1.0 && @frame_count > 0
      @current_frame_rate = @frame_count / sample_window
      @frame_count = 0
      @window_timer = nil
    end
  end

  def render_frame
    output_buffer = []

    scene = renderer.call(
      map: map,
      field_of_view: field_of_view,
      position: player.position,
      angle: player.angle,
      canvas_width: canvas_width,
      canvas_height: canvas_height,
    )

    scene.each { |line_chars| output_buffer << line_chars }

    if @show_map
      hud = map
        .overlay_player(@player.position, @player.angle)
        .rows

      hud.push "Current frame rate: #{@current_frame_rate.floor}".chars
      hud.push "Position: #{player.position.to_a}".chars
      hud.push "Resolution: #{canvas_width} x #{canvas_height}".chars

      hud.each_with_index do |line, i|
        output_buffer[i] = line + output_buffer[i].drop(line.length)
      end
    end

    if map.goal?(player.position)
      write_buffer(win_frame)
      wait_for_key
      next_level or stop
    else
      write_buffer(output_buffer)
    end
  end

  def wait_for_key
    initial_key_count = @input_buffer.length
    10.times do
      sleep(0.1)
      key_count = @input_buffer.length
      break if key_count > initial_key_count
    end
  end

  def next_level
    if @maps[@current_map_index + 1]
      @current_map_index +=1
      reset_map
      true
    end
  end

  def map
    @maps[@current_map_index]
  end

  def reset_map
    @player.position = map.player_start_position
  end

  def write_buffer(buffer)
    io.write(ANSI.cursor_top_left + buffer.map(&:join).join("\r\n"))
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
