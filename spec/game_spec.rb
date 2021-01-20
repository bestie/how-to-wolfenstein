require "spec_helper"
require "stringio"

Thread.abort_on_exception = true
Thread.current.name = "main"

RSpec.describe Game do
  $total_frames = 0
  $log = StringIO.new

  subject(:game) {
    Game.new(
      io: io,
      maps: maps,
      player: player,
      renderer: renderer,
    )
  }

  let(:io) { MockIO.new(width: width, height: height) }
  let(:maps) { [map] }
  let(:player) { Player.new(speed: speed, turn_rate: turn_rate, angle: current_angle, position: current_position) }
  let(:renderer) { double(:renderer, call: frame) }

  let(:map) { Map.from_string(level_string) }
  let(:current_position) { map.player_start_position }
  let(:current_angle) { π / 2.0 }
  let(:frame) { [ ["$"] * width ] * height }
  let(:width) { 20 }
  let(:height) { 20 }
  let(:speed) { 1 }
  let(:turn_rate) { π/8.0 }

  context "on game start" do
    it "hides the cursor and saves the terminal state" do
      start_game

      expect(io.screen_buffer.first).to include(ANSI.hide_cursor)
      expect(io.screen_buffer.first).to include(ANSI.save_terminal_state)
    end

    it "places the player in the map's start position" do
      start_game
      allow_game_thread_to_run

      expect(player.position).to eq(map.player_start_position)
    end
  end

  context "while the game is running" do
    it "continually renders frames without user input" do
      start_game

      (2..10).each do |i|
        allow_game_thread_to_run

        expect(io.screen_buffer.length).to eq(i)
      end
    end

    it "moves the cursor to the top left before writing the frame" do
      start_game

       3.times do
        allow_game_thread_to_run

        expect(io.screen_buffer.last).to start_with(ANSI.cursor_top_left)
      end
    end

    it "prints both carriage return and line feed at the end of each line" do
      start_game

      allow_game_thread_to_run

      lines = io.screen_buffer.last.split("\r\n")
      expect(lines.length).to eq(height)
    end

    context "when the user presses 'w'" do
      it "walks the player forward" do
        start_game

        expect { io.type_char("w") }
          .to change { player.position.x }
          .by(speed)
      end
    end

    context "when the user presses 'a'" do
      it "strafes the player left" do
        start_game

        expect {  io.type_char("a") }
          .to change { player.position.y }
          .by(-speed)
      end
    end

    context "when the user presses 's'" do
      it "walks the player backwards" do
        start_game

        expect { io.type_char("s") }
          .to change { player.position.x }
          .by(-speed)
      end
    end

    context "when the user presses 'd'" do
      it "strafes the player right" do
        start_game

        expect { io.type_char("d") }
          .to change { player.position.y }
          .by(speed)
      end
    end

    context "when the user presses right arrow" do
      it "increases the player's angle" do
        start_game

        expect {
          io.type_char("\e")
          io.type_char("[")
          io.type_char("C")
        }.to change { player.angle }
          .by(turn_rate)
      end
    end

    context "when the user presses left arrow" do
      it "decreases the player's angle" do
        start_game

        expect {
          io.type_char("\e")
          io.type_char("[")
          io.type_char("D")
        }.to change { player.angle }
          .by(-turn_rate)
      end
    end

    context "when the user presses 'm'" do
      let(:map_line) { "#   →   G" }
      let(:current_angle) { π / 2.0 }

      it "shows / hides the map" do
        start_game
        allow_game_thread_to_run

        expect(io.current_output).to include(map_line)

        io.type_char("m")

        allow_game_thread_to_run

        expect(io.current_output).not_to include(map_line)
      end
    end

    context "when the player is against a wall" do
      it "does not allow the player to walk through the wall" do
        start_game

        io.type_char("s")
        io.type_char("s")
        io.type_char("s")
        expect { io.type_char("s") }.not_to change { player.position }

        io.type_char("a")
        io.type_char("a")
        expect { io.type_char("a") }.not_to change { player.position }

        io.type_char("w")
        io.type_char("w")
        io.type_char("w")
        io.type_char("w")
        io.type_char("w")
        io.type_char("w")
        expect { io.type_char("w") }.not_to change { player.position }

        io.type_char("d")
        io.type_char("d")
        expect { io.type_char("d") }.not_to change { player.position }
      end
    end
  end

  context "when the player reaches the goal" do
    before do
      start_game
      allow_game_thread_to_run
    end

    let(:player) { Player.new(angle: π/2.0, speed:1.0) }

    it "renders the 'win screen'" do
      move_to_goal

      allow_game_thread_to_run

      expect(io.current_output).to match(win_screen)
    end

    context "when there is a next level" do
      let(:maps) { [map, map2] }

      let(:map2) { Map.from_string(<<~MAP) }
        #########
        #       #
        G       #
        #X      #
        #########
      MAP

      it "starts the player in the next level" do
        move_to_goal

        allow_game_thread_to_run

        expect(io.current_output).to match(win_screen)

        io.type_char("f") # to pay respect (any input is fine here)
        allow_game_thread_to_run

        expect(io.current_output).not_to match(win_screen)

        move_to_goal2

        allow_game_thread_to_run

        expect(io.current_output).to match(win_screen)
      end

      def move_to_goal2
        io.type_char("a")
        io.type_char("s")
      end
    end

    def move_to_goal
      4.times { io.type_char("w") }
    end
  end

  context "on exit" do
    before do
      start_game
      allow_game_thread_to_run
    end

    it "restores the terminal state and unhides the cursor" do
      game.stop
      allow_game_thread_to_run

      expect(io.screen_buffer.last).to include(ANSI.restore_terminal_state)
      expect(io.screen_buffer.last).to include(ANSI.unhide_cursor)
    end

    it "kills its input thread" do
      game.stop
      allow_game_thread_to_run
      io.shutdown

      good_threads = [Thread.main, @game_thread]
      other_threads = Thread.list - good_threads

      expect(other_threads).to be_empty
    end
  end

  context "when the user presses ctrl-c" do
    before do
      start_game
      allow_game_thread_to_run
    end

    it "stops the game" do
      io.type_char(?\C-c, wait: 0)

      5.times do
        break if game.over?
        sleep(0.01)
      end

      expect(game).to be_over

      # It would be cool to check no more frames are rendered but I'm not sure
      # how to check it's dead without waiting and that's too slow for me :)
      # expect { allow_game_thread_to_run }
      #   .not_to change { io.screen_buffer.size }
    end

    it "restores the terminal state and unhides the cursor" do
      io.type_char(?\C-c, wait: 0)

      allow_game_thread_to_run

      expect(io.screen_buffer.last).to include(ANSI.restore_terminal_state)
      expect(io.screen_buffer.last).to include(ANSI.unhide_cursor)
    end

    it "kills its input thread" do
      io.type_char(?\C-c, wait: 0)
      allow_game_thread_to_run
      io.shutdown

      good_threads = [Thread.main, @game_thread]
      other_threads = Thread.list - good_threads

      expect(other_threads).to be_empty
    end
  end

  context "when an exception is raised during game play" do
    before do
      allow(renderer).to receive(:call).and_raise(RuntimeError)
    end

    it "restores the terminal state and unhides the cursor" do
      start_game
      allow_game_thread_to_run

      expect(io.screen_buffer.last).to include(ANSI.restore_terminal_state)
      expect(io.screen_buffer.last).to include(ANSI.unhide_cursor)
    end
  end

  def start_game
    @game_thread = Thread.new { game.start }
    @game_thread.name = "game thread"

    10.times do |attempt|
      sleep(0.001)
      break if io.both_blocked?
    end

    unless io.both_blocked?
      raise "timed out waiting io block"
    end
  end

  def allow_game_thread_to_run
    unblock_io_write

    # Put the main thread to sleep to allow the game thread to run.
    # This is a max time, MockIO will wake up the main thread after the game
    # writes to the screen buffer. Most pauses here are ~2ms for me.
    max_time = 2
    start = Time.now.to_f
    sleep(max_time)
    finish = Time.now.to_f
    sleep_time = finish - start

    if sleep_time > (max_time * 0.9)
      warn "Was not woken from sleep, slept for #{sleep_time.round(4)}s"
    end
  end

  def unblock_io_write
    io.unblock_writing
  end

  after do
    io.shutdown
    game.stop
    @game_thread.terminate

    # $log.rewind
    # log_contents = $log.read
    # puts log_contents unless log_contents.empty?
  end

  class MockIO
    def initialize(width:, height:)
      @keyboard_queue = Queue.new
      @screen_buffer = []
      @block_writing = false
      @block_reading = false
      @winsize = [height, width]
      @main_thread = Thread.main
      @stop = false
    end

    attr_reader :winsize
    attr_reader :screen_buffer, :keyboard_queue

    # Runs in the game input thread, blocks until the queue has data.
    # Before blocking it wakes the main thread which may be sleeping, waiting
    # for the input thread to finish a loop.
    def getch
      wake_up_main_thread
      @block_reading = true
      char = @keyboard_queue.deq
      @block_reading = false
      char
    end

    # Runs in the game rendering thread and is called at the end of the
    # rendering loop. It will block after consuming the first write by looping.
    # A call to #unblock_writing will stop the loop and unblock the rendering
    # thread which, in most cases, will loop, call this method again and be
    # blocked.
    # In the case of #shutdown being called the blocking behavior is disabled,
    # this is used at the end of each test.
    def write(string)
      @screen_buffer << string
      @block_writing = true
      wake_up_main_thread

      loop do
        if @block_writing && !@stop
          sleep(0.001)
        else
          break
        end
      end
    end

    # This will unblock #getch which is running in the game's input thread.
    # The main thread should sleep so the input thread can process the char.
    # After input is processed the input loop will call #getch which will wake
    # the main thread, skipping most of this sleep time.
    def type_char(char, wait: 0.5)
      @keyboard_queue.enq(char)

      sleep(wait)
    end

    def both_blocked?
      @block_reading && @block_writing
    end

    def unblock_writing
      @block_writing = false
    end

    def shutdown
      @stop = true
    end

    def current_output
      @screen_buffer.last.gsub("\e", "").gsub("\r", "")
    end

    private

    def wake_up_main_thread
      if @main_thread.alive?
        @main_thread.run
      end
    end
  end

  let(:level_string) { <<~LEVEL }
    #########
    #       #
    #   X   G
    #       #
    #########
  LEVEL

  def win_screen
    include("\u{1F645} ")
  end
end
