require "spec_helper"

require "map"

RSpec.describe Map do
  subject(:map) { Map.from_string(level_string) }

  describe "#in_bounds?" do
    context "when query position in within the walls" do
      it "returns true" do
        expect(map.in_bounds?(Vector[1.0, 1.0])).to be(true)
        expect(map.in_bounds?(Vector[5.5, 3.5])).to be(true)
        expect(map.in_bounds?(Vector[7.9, 3.9])).to be(true)
      end
    end

    context "when query position in within a wall tile" do
      it "returns false" do
        expect(map.in_bounds?(Vector[0.5, 0.5])).to be(false)
        expect(map.in_bounds?(Vector[3.5, 0.5])).to be(false)
        expect(map.in_bounds?(Vector[0.5, 3.5])).to be(false)
        expect(map.in_bounds?(Vector[8.0, 4.0])).to be(false)
      end
    end

    context "when query position within a goal tile" do
      it "returns true" do
        expect(map.in_bounds?(Vector[8.1, 2.5])).to be(true)
      end
    end

    context "when query position in outside map" do
      it "returns false" do
        expect(map.in_bounds?(Vector[-10.0, -10.0])).to be(false)
        expect(map.in_bounds?(Vector[100.0, 1000.0])).to be(false)
      end
    end
  end

  describe "#rows" do
    it "returns a 2D array character representation of the level" do
      expect(map.rows.length).to eq(5)
      expect(map.rows.map(&:length).uniq).to eq([9])
    end

    context "when rejoining the character array" do
      it "produces the original string input" do
        recoverd_string = map.rows.map(&:join).join("\n")
        original_string_without_line_extra_line_breaks = level_string[1..-2]

        expect(recoverd_string).to eq(original_string_without_line_extra_line_breaks)
      end
    end
  end

  describe "#player_start_position" do
    it "returns the floating point centre position of denoted by `X`" do
      expect(map.player_start_position).to eq(Vector[4.5, 2.5])
    end
  end

  describe "#overlay_player" do
    let(:position) { Vector[2.3, 2.8] }
    let(:angle) { 0.0 }

    it "does not mutate the existing map" do
      expect { map.overlay_player(position, angle) }
        .not_to change { map.rows[2, 2] }
    end

    it "returns a new map with updated player position" do
      overlay_char = map.overlay_player(position, angle).rows[2][2]

      expect(overlay_char).to eq(Map::Arrows::NORTH)
    end

    context "when player faces north" do
      let(:angle) { 0.0 }
      it "substitutes an up arrow" do
        overlay_char = map.overlay_player(position, angle).rows[2][2]

        expect(overlay_char).to eq(Map::Arrows::NORTH)
      end
    end

    context "when player faces east" do
      let(:angle) { π / 2.0 }
      it "substitutes an right arrow" do
        overlay_char = map.overlay_player(position, angle).rows[2][2]

        expect(overlay_char).to eq(Map::Arrows::EAST)
      end
    end

    context "when player faces south" do
      let(:angle) { π }
      it "substitutes an right arrow" do
        overlay_char = map.overlay_player(position, angle).rows[2][2]

        expect(overlay_char).to eq(Map::Arrows::SOUTH)
      end
    end

    context "when player faces west" do
      let(:angle) { π * 3 / 2.0 }
      it "substitutes an right arrow" do
        overlay_char = map.overlay_player(position, angle).rows[2][2]

        expect(overlay_char).to eq(Map::Arrows::WEST)
      end
    end
  end

  describe "#goal?" do
    context "when the given position is within the goal cell" do
      it "returns true" do
        expect(map.goal?(Vector[8.0, 2.0])).to be true
        expect(map.goal?(Vector[8.9, 2.9])).to be true
      end
    end

    context "when the given position is outside the goal cell" do
      it "returns false" do
        expect(map.goal?(Vector[7.9, 1.9])).to be false
        expect(map.goal?(Vector[8.1, 1.9])).to be false
        expect(map.goal?(Vector[9.1, 2.1])).to be false
        expect(map.goal?(Vector[8.1, 3.1])).to be false
      end
    end
  end

  describe "#wall?" do
    context "when position is inside a wall element" do
      it "returns true" do
        expect(map.wall?(Vector[0.9, 0.9])).to be true
        expect(map.wall?(Vector[1.0, 4.1])).to be true
        expect(map.wall?(Vector[8.0, 0.9])).to be true
      end
    end

    context "when position is inside the goal element" do
      it "returns true" do
        expect(map.wall?(Vector[8.1, 2.1])).to be true
        expect(map.wall?(Vector[8.9, 2.9])).to be true
      end
    end

    context "when position is not inside wall element" do
      it "returns false" do
        expect(map.wall?(Vector[1.0, 1.0])).to be false
        expect(map.wall?(Vector[1.0, 3.9])).to be false
        expect(map.wall?(Vector[7.9, 1.5])).to be false
      end
    end
  end

  let(:level_string) do
"""
#########
#       #
#   X   G
#       #
#########
"""
  end
end
