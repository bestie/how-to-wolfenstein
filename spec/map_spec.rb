require "spec_helper"

require "map"

RSpec.describe Map do
  subject(:map) { Map.from_string(level_string) }

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

  let(:level_string) do
"""
#########
#       #
#   X   #
#       #
#########
"""
  end
end
