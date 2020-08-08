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

  let(:level_string) do
"""
#########
#       #
#   O   #
#       #
#########
"""
  end
end
