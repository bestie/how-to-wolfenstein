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

    expect(scene.length).to eq(canvas_height)
    expect(scene.map(&:length).uniq).to eq([canvas_width])
  end

  it "traces the wall distance column" do
    renderer.call

    expect(tracer).to have_received(:wall_position)
      .exactly(canvas_width).times
  end

  it "traces the wall distance for each angle in field of view" do
    angles = []
    allow(tracer).to receive(:wall_position) do |**args|
      angles.push(args.fetch(:angle))
      wall_position
    end

    renderer.call

    expect(angles.first).to eq(-π/4.0)
    expect(angles.last).to eq(π/4.0)
  end

  context "when the column's distance is 4.5" do
    let(:distance_to_wall) { 4.5 }

    it "renders the visible wall vertical center" do
      scene = renderer.call
      column = scene.transpose[0]

      expect(column.drop(11).take(18)).to eq([ANSI.red("*")] * 18)
    end

    it "renders the ceiling and floor the same size" do
      scene = renderer.call
      column = scene.transpose[0]

      expect(column.take(11)).to eq([" "] * 11)
      expect(column.drop(11).drop(18)).to eq(["."] * 11)
    end
  end

  context "when the column's wall distance is 2.0" do
    let(:wall_position) { Vector[0.0, 2.0] }

    it "renders only wall" do
      scene = renderer.call
      column = scene.transpose[0]

      expect(column).to eq([ANSI.black_on_red("%")] * 40)
    end
  end

  context "when the column's wall distance is 0" do
    let(:wall_position) { Vector[0.0, 0.0] }

    it "renders only wall" do
      scene = renderer.call
      column = scene.transpose[0]

      expect(column).to eq([ANSI.black_on_red(" ")] * 40)
    end
  end

  context "when that column's distance is max drawing distance" do
    let(:wall_position) { Vector[0.0, 10.0] }

    it "renders the visible wall vertical center" do
      scene = renderer.call
      column = scene.transpose[0]

      expect(count_wall_chars(column)).to eq(8)
    end
  end

  context "when that column's distance is beyond max drawing distance" do
    let(:wall_position) { Vector[0.0, 10.1] }

    it "renders the visible wall vertical center" do
      scene = renderer.call
      column = scene.transpose[0]

      expect(count_wall_chars(column)).to eq(0)
    end
  end

  context "when that column falls on the goal tile" do
    let(:wall_position) { Vector[0.0, 1.0] }

    it "renders in green" do
      allow(map).to receive(:goal?).and_return(true)

      scene = renderer.call
      column = scene.transpose[0]

      expect(column).to include(ANSI.black_on_green("*"))
    end
  end

  def count_wall_chars(column)
    column.count { |char| ANSIRenderer::WALL_GRADIENT.include?(char) }
  end
end
