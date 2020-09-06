require "spec_helper"

require "map"
require "ray_tracer"

RSpec.describe RayTracer do
  subject(:tracer) { RayTracer.new }

  let(:map) {
    Map.from_string(
      """
#############
#           #
#           #
#           #
#           #
#           #
#     X     #
#           #
#           #
G           #
#           #
#           #
#############
      """.strip
    )
  }

  let(:map_dimension) { 5.5 }
  let(:map_diagonal) { Math.sqrt(2*map_dimension**2) }

  let(:resolution) { RayTracer::RESOLUTION }

  describe "#distance_to_wall" do
    context "from start position, looking north" do
      let(:position) { map.player_start_position }
      let(:angle) { 0 }

      it "measures distance to center wall surface" do
        distance = tracer.distance_to_wall(map: map, from: position, angle: angle)

        expect(distance).to eq_within_resolution(map_dimension)
      end
    end

    context "measures distance to looking east" do
      let(:position) { map.player_start_position }
      let(:angle) { π / 2.0 }

      it "finds the center-left wall surface" do
        distance = tracer.distance_to_wall(map: map, from: position, angle: angle)

        expect(distance).to eq_within_resolution(map_dimension)
      end
    end

    context "from start position looking south east" do
      let(:position) { map.player_start_position }
      let(:angle) { π * 3/4.0 }

      it "measures distance to the bottom-left corner" do
        distance = tracer.distance_to_wall(map: map, from: position, angle: angle)

        expect(distance).to eq_within_resolution(map_diagonal)
      end
    end

    context "from arbitrary position looking north west" do
      let(:position) { Vector[10.0, 10.0] }
      let(:angle) { π * 7/4.0 }

      let(:expected_distance_from_corner) {
        Math.sqrt(2*relative_x_distance_from_corner**2)
      }
      let(:relative_x_distance_from_corner) { position.x - 1 }

      it "measures distance tos the top-left corner" do
        distance = tracer.distance_to_wall(map: map, from: position, angle: angle)

        expect(distance).to eq_within_resolution(expected_distance_from_corner)
      end
    end

    context "when facing the goal" do
      let(:position) { Vector[3.5, 8.5] }
      let(:angle) { π * 3/2.0 }

      it "measures distance to goal position as if it were a wall" do
        distance = tracer.distance_to_wall(map: map, from: position, angle: angle)

        expect(distance).to eq_within_resolution(2.5)
      end
    end
  end

  describe "#wall_position" do
    context "from start position, looking north" do
      let(:position) { map.player_start_position }
      let(:angle) { 0 }

      it "finds the top, center wall surface" do
        wall_pos = tracer.wall_position(map: map, from: position, angle: angle)

        expect(wall_pos).to match_vector(6.5, 1.0, tolerance: resolution)
      end
    end

    context "from start position, looking east" do
      let(:position) { map.player_start_position }
      let(:angle) { π / 2.0 }

      it "finds the center-left wall surface" do
        wall_pos = tracer.wall_position(map: map, from: position, angle: angle)

        expect(wall_pos).to match_vector(12.0, 6.5, tolerance: resolution)
      end
    end

    context "from start position looking south east" do
      let(:position) { map.player_start_position }
      let(:angle) { π * 3/4.0 }

      it "finds the bottom-left corner" do
        wall_pos = tracer.wall_position(map: map, from: position, angle: angle)

        expect(wall_pos).to match_vector(12.0, 12.0, tolerance: resolution)
      end
    end

    context "from arbitrary position looking north west" do
      let(:position) { Vector[10.0, 10.0] }
      let(:angle) { π * 7/4.0 }

      it "finds the top-left corner" do
        wall_pos = tracer.wall_position(map: map, from: position, angle: angle)

        expect(wall_pos).to match_vector(1.0, 1.0, tolerance: resolution)
      end
    end

    context "when facing the goal" do
      let(:position) { Vector[3.5, 8.5] }
      let(:angle) { π * 3/2.0 }

      it "finds the goal position as if it were a wall" do
        wall_pos = tracer.wall_position(map: map, from: position, angle: angle)

        expect(wall_pos).to match_vector(1.0, 8.5, tolerance: resolution)
      end
    end
  end

  def eq_within_resolution(expected)
    be_within(resolution).of(expected)
  end
end
