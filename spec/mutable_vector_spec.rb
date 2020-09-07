require "spec_helper"

require "mutable_vector"

RSpec.describe MutableVector do
  let(:vec) { MutableVector.new(1, 2) }
  let(:other) { Vector[2, 2] }

  describe "#[]" do
    let(:vec) { MutableVector.new(3, 4) }

    it "indexes into the vector" do
      expect([vec[0], vec[1]]).to eq([3, 4])
    end

    context "when argument is out of bounds" do
      it "rasies an IndexError" do
        expect { vec[-1] }.to raise_error(IndexError)
        expect { vec[2] }.to raise_error(IndexError)
      end
    end
  end

  describe "#==" do
    context "when the other vector has equal components" do
      it "is equal" do
        expect(MutableVector.new(3,3)).to eq(MutableVector.new(3,3))
      end
    end

    context "when the other vector's components are not equal" do
      it "is not equal" do
        expect(MutableVector.new(2,2)).not_to eq(MutableVector.new(3,3))
      end
    end
  end

  describe "#magnitude" do
    let(:vec) { MutableVector.new(3, 4) }

    it "returns the scalar length of the vector" do
      expect(vec.magnitude).to eq(5.0)
    end
  end

  describe "#+" do
    it "adds the other vector to itself" do
      vec + other

      expect(vec.to_a).to eq([3, 4])
    end

    it "returns self" do
      expect(vec + other).to be(vec)
    end
  end

  describe "#-" do
    it "subtracts the other vector from itself" do
      vec - other

      expect(vec.to_a).to eq([-1, 0])
    end

    it "returns self" do
      expect(vec - other).to be(vec)
    end
  end

  describe "#*" do
    it "multuplies itself by the other vector" do
      vec * 3

      expect(vec.to_a).to eq([3, 6])
    end

    it "returns self" do
      expect(vec * 3).to be(vec)
    end
  end

  describe "#to_vector" do
    it "returns a regular, immuatble Vector" do
      expect(vec.to_vector).to be_a(Vector)
    end

    it "returns a vector with the same values" do
      expect(vec.to_vector.to_a).to eq(vec.to_a)
    end
  end
end
