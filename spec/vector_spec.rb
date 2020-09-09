require "spec_helper"

RSpec.describe Vector do
  let(:vec) { Vector[1, 2] }
  let(:other) { Vector[2, 2] }
  let(:unit_length_45_deg) { Math.sqrt(0.5) }

  describe ".from_angle" do
    let(:u) { unit_length_45_deg }

    it "converts to our y-inverted co-ordinate system" do
      expect(Vector.from_angle(0)).to         eq(Vector[+0, -1])
      expect(Vector.from_angle(π*1/4.0)).to   eq(Vector[+u, -u])
      expect(Vector.from_angle(π*2/4.0)).to   eq(Vector[+1, +0])
      expect(Vector.from_angle(π*3/4.0)).to   eq(Vector[+u, +u])
      expect(Vector.from_angle(π)).to         eq(Vector[+0, +1])
      expect(Vector.from_angle(π*5/4.0)).to   eq(Vector[-u, +u])
      expect(Vector.from_angle(π*6/4.0)).to   eq(Vector[-1, +0])
      expect(Vector.from_angle(π*7/4.0)).to   eq(Vector[-u, -u])
      expect(Vector.from_angle(π*8/4.0)).to   eq(Vector[+0, -1])
    end
  end

  describe "#magnitude" do
    let(:vec) { Vector.new(3, 4) }

    it "returns the scalar length of the vector" do
      expect(vec.magnitude).to eq(5.0)
    end
  end

  describe "#+" do
    it "adds the other vector to itself" do
      expect(vec + other).to eq(Vector[3, 4])
    end
  end

  describe "#-" do
    it "subtracts the other vector from itself" do
      expect(vec - other).to eq(Vector[-1, 0])
    end
  end

  describe "#*" do
    it "multuplies itself by the other vector" do
      expect(vec * 3).to eq(Vector[3, 6])
    end
  end

  describe "#==" do
    context "when the other vector has equal components" do
      it "is equal" do
        expect(Vector.new(3,4)).to eq(Vector.new(3,4))
      end
    end

    context "when the other vector has almost equal floating point components (within tolerance)" do
      let(:n) { Math.sqrt(2.0) }
      let(:delta) { 10**-6 }

      it "is equal" do
        expect(Vector.new(n, n)).to eq(Vector.new(n+delta, n-delta))
      end
    end

    context "when the other vector has almost equal floating point components (not within tolerance)" do
      let(:n) { Math.sqrt(2.0) }
      let(:delta) { 10**-5 }

      it "is not equal" do

        expect(Vector.new(n, n)).not_to eq(Vector.new(n+delta, n-delta))
      end
    end

    context "when the other vector's components are not equal" do
      it "is not equal" do
        expect(Vector.new(2,2)).not_to eq(Vector.new(3,3))
      end
    end
  end

end
