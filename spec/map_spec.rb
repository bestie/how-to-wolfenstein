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
    let(:player_position) { Vector[2.3, 2.8] }
    let(:position2) { Vector[3.3, 2.8] }

    it "returns a new map with updated player position" do
      expect(map.overlay_player(player_position).rows[2][2]).to eq("O")
    end

    it "does not leave mutated the previous map" do
      expect { map.overlay_player(player_position) }
        .not_to change { map.rows[2, 2] }
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
