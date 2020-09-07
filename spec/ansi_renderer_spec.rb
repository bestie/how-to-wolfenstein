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

  let(:map) { double(:map) }
  let(:field_of_view) { π / 2.0 }
  let(:canvas_width) { 80 }
  let(:canvas_height) { 40 }
  let(:tracer) { double(:tracer, distance_to_wall: distance_to_wall) }

  let(:distance_to_wall) { 4.5 }
  let(:position) { Vector[0.0, 0.0] }
  let(:angle) { 0.0 }

  it "returns a 2D character array the size of the canvas" do
    scene = renderer.call

    expect(scene.length).to eq(canvas_height)
    expect(scene.map(&:length).uniq).to eq([canvas_width])
  end

  it "traces the wall distance column" do
    scene = renderer.call

    expect(tracer).to have_received(:distance_to_wall)
      .exactly(canvas_width).times
  end

  it "traces the wall distance for each angle in field of view" do
    angles = []
    allow(tracer).to receive(:distance_to_wall) do |**args|
      angles.push(args.fetch(:angle))
      distance_to_wall
    end

    scene = renderer.call

    expect(angles.first).to eq(-π/4.0)
    expect(angles.last).to eq(π/4.0)
  end

  context "when the column's distance is 4.5" do
    let(:distance_to_wall) { 4.5 }

    it "renders the visible wall vertical center" do
      scene = renderer.call
      column = scene.transpose[0]

      expect(column.drop(11).take(18)).to eq([ANSI.black_on_red("%")] * 18)
    end

    it "renders the ceiling and floor the same size" do
      scene = renderer.call
      column = scene.transpose[0]

      expect(column.take(11)).to eq([" "] * 11)
      expect(column.drop(11).drop(18)).to eq(["."] * 11)
    end
  end

  context "when the column's wall distance is 2.0" do
    let(:distance_to_wall) { 2.0 }

    it "renders only wall" do
      scene = renderer.call
      column = scene.transpose[0]

      expect(column).to eq([ANSI.black_on_red("=")] * 40)
    end
  end

  context "when the column's wall distance is 0" do
    let(:distance_to_wall) { 0.0 }

    it "renders only wall" do
      scene = renderer.call
      column = scene.transpose[0]

      expect(column).to eq([ANSI.black_on_red(" ")] * 40)
    end
  end

  context "when that column's distance is max drawing distance" do
    let(:distance_to_wall) { 10 }

    it "renders the visible wall vertical center" do
      scene = renderer.call
      column = scene.transpose[0]

      expect(count_wall_chars(column)).to eq(8)
    end
  end

  context "when that column's distance is beyond max drawing distance" do
    let(:distance_to_wall) { 10.1 }

    it "renders the visible wall vertical center" do
      scene = renderer.call
      column = scene.transpose[0]

      expect(count_wall_chars(column)).to eq(0)
    end
  end

  def count_wall_chars(column)
    column.count { |char| ANSIRenderer::WALL_GRADIENT.include?(char) }
  end
end
