require "spec_helper"

require "ansi_renderer"

RSpec.describe ANSIRenderer do
  subject(:renderer) {
    ANSIRenderer.new(
      map: map,
      tracer: tracer,
      field_of_view: field_of_view,
      position: position,
      angle: angle,
      canvas_width: canvas_width,
      canvas_height: canvas_height,
    )
  }

  let(:map) { double(:map, "wall?" => true, "goal?" => false) }
  let(:field_of_view) { π / 2.0 }
  let(:canvas_width) { 80 }
  let(:canvas_height) { 40 }
  let(:tracer) { double(:tracer, wall_position: wall_position) }

  let(:wall_position) { Vector[0.0, 4.5] }
  let(:position) { Vector[0.0, 0.0] }
  let(:angle) { 0.0 }

  it "returns a 2D character array the size of the canvas" do
    scene = renderer.call

    height = scene.length
    widths = scene.map(&:length).uniq
    raise "Scene contains uneven widths" if widths.length > 1
    width = widths.fetch(0)

    expect([width, height]).to eq([canvas_width, canvas_height])
  end

  it "measures the wall distance once for each column" do
    renderer.call

    expect(tracer).to have_received(:wall_position)
      .exactly(canvas_width).times
  end

  it "measures the wall distance for the full range of the field of view" do
    angles = []
    allow(tracer).to receive(:wall_position) do |args|
      angles.push(args.fetch(:angle))
      wall_position
    end

    renderer.call

    aggregate_failures do
      expect(angles.first).to eq(-π/4.0)
      expect(angles.last).to eq(π/4.0)
    end
  end

  context "when the column's distance is 4.5" do
    let(:distance_to_wall) { 4.5 }
    let(:floor_size) { 11 }
    let(:wall_size) { canvas_height - floor_size * 2 }

    it "renders the visible wall vertical center" do
      scene = renderer.call
      column = center_column(scene)

      expect(column.drop(floor_size).take(wall_size))
        .to match([any_wall_char] * wall_size)
    end

    it "renders the ceiling and floor the same size" do
      scene = renderer.call
      column = center_column(scene)

      floor_rendering = [" "] * floor_size
      ceiling_rendering = ["."] * floor_size

      expect(column.take(floor_size)).to eq(floor_rendering)
      expect(column.drop(floor_size).drop(wall_size)).to eq(ceiling_rendering)
    end
  end

  context "when the column's wall distance is 2.0" do
    let(:wall_position) { Vector[0.0, 2.0] }

    it "renders only wall" do
      scene = renderer.call
      column = center_column(scene)

      expect(column).to match([any_wall_char] * 40)
    end
  end

  context "when the column's wall distance is 0" do
    let(:wall_position) { Vector[0.0, 0.0] }

    it "renders only wall" do
      scene = renderer.call
      column = center_column(scene)

      expect(column).to match([any_wall_char] * 40)
    end
  end

  context "when that column's distance is max drawing distance" do
    let(:wall_position) { Vector[0.0, 10.0] }

    it "renders the visible wall vertical center" do
      scene = renderer.call
      column = center_column(scene)

      expect(count_wall_chars(column)).to eq(8)
    end
  end

  context "when that column's distance is beyond max drawing distance" do
    let(:wall_position) { Vector[0.0, 10.4] }

    it "renders the no wall" do
      scene = renderer.call
      column = center_column(scene)

      expect(count_wall_chars(column)).to eq(0)
    end
  end

  context "when that column falls on the goal tile" do
    let(:wall_position) { Vector[0.0, 1.0] }

    it "renders in green" do
      allow(map).to receive(:goal?).and_return(true)

      scene = renderer.call
      column = center_column(scene)

      expect(column).to include(black_on_green_char)
    end
  end

  context "with a real map and tracer" do
    let(:tracer) { RayTracer.new }
    let(:map) { Map.from_string(<<~MAP) }
      #########
      #       #
      #       #
      #       #
      #   X   #
      G       #
      #########
    MAP

    context "player faces a straight wall" do
      let(:position) { map.player_start_position }
      let(:angle) { 0.0 }

      it "renders all wall columns the same height" do
        scene = renderer.call

        wall_heights = scene.transpose.map { |col| count_wall_chars(col) }
        expect(wall_heights.uniq).to eq([22])
      end
    end
  end

  def count_wall_chars(column)
    column.count { |char| ANSIRenderer::WALL_GRADIENT.include?(char) }
  end

  def center_column(scene)
    columns = scene.transpose
    columns[columns.length / 2]
  end

  def black_on_green_char
    starting_with("\e[42;30m")
  end

  def any_wall_char
    chars = ANSIRenderer::WALL_GRADIENT

    chars.reduce(eq(chars.first)) { |agg, char|
      agg.or(eq(char))
    }
  end

  def print_scene(scene)
    scene.each { |l| puts(l.join) }
  end
end
