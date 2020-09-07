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

  let(:resolution) { RayTracer::RESOLUTION }

  describe "#wall_position" do
    context "from start position, looking north" do
      let(:position) { map.player_start_position }
      let(:angle) { 0 }

      it "find the top center wall surface" do
        wall_position = tracer.wall_position(map: map, from: position, angle: angle)

        expect(wall_position).to match_vector(6.5, 1.0, tolerance: resolution)
      end
    end

    context "from start position, looking east" do
      let(:position) { map.player_start_position }
      let(:angle) { π / 2.0 }

      it "finds the center-left wall surface" do
        wall_position = tracer.wall_position(map: map, from: position, angle: angle)

        expect(wall_position).to match_vector(12.0, 6.5, tolerance: resolution)
      end
    end

    context "from start position, looking south east" do
      let(:position) { map.player_start_position }
      let(:angle) { π * 3/4.0 }

      it "finds the bottom-left corner" do
        wall_position = tracer.wall_position(map: map, from: position, angle: angle)

        expect(wall_position).to match_vector(12.0, 12.0, tolerance: resolution)
      end
    end

    context "from arbitrary position looking north west" do
      let(:position) { Vector[10.0, 10.0] }
      let(:angle) { π * 7/4.0 }

      it "finds the top-left corner" do
        wall_position = tracer.wall_position(map: map, from: position, angle: angle)

        expect(wall_position).to match_vector(1.0, 1.0, tolerance: resolution)
      end
    end

    context "when facing the goal" do
      let(:position) { Vector[3.5, 8.5] }
      let(:angle) { π * 3/2.0 }

      it "finds the goal position as if it were a wall" do
        wall_position = tracer.wall_position(map: map, from: position, angle: angle)

        expect(wall_position).to match_vector(1.0, 8.5, tolerance: resolution)
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
end
