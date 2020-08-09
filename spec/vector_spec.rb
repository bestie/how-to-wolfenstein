require "spec_helper"

RSpec.describe Vector do
  let(:unit_length_45_deg) { Math.sqrt(0.5) }

  describe ".from_angle" do
    it "converts to our y-inverted co-ordinate system" do
      u = unit_length_45_deg

      expect(Vector.from_angle(0)).to         match_vector(+0, -1)
      expect(Vector.from_angle(π*1/4.0)).to   match_vector(+u, -u)
      expect(Vector.from_angle(π*2/4.0)).to   match_vector(+1, +0)
      expect(Vector.from_angle(π*3/4.0)).to   match_vector(+u, +u)
      expect(Vector.from_angle(π)).to         match_vector(+0, +1)
      expect(Vector.from_angle(π*5/4.0)).to   match_vector(-u, +u)
      expect(Vector.from_angle(π*6/4.0)).to   match_vector(-1, +0)
      expect(Vector.from_angle(π*7/4.0)).to   match_vector(-u, -u)
      expect(Vector.from_angle(π*8/4.0)).to   match_vector(+0, -1)
    end
  end
end
