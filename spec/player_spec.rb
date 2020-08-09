require "spec_helper"

RSpec.describe Player do
  subject(:player) {
    Player.new(
      position: origin,
      speed: speed,
      angle: angle,
    )
  }

  let(:speed) { 1.0 }
  let(:origin) { Vector[0, 0] }
  let(:angle) { 0 }
  let(:unit_length_45_deg) { Math.sqrt(0.5) }

  describe "#move_forward" do
    context "facing south" do
      let(:angle) { π }
      let(:speed) { 2.0 }

      it "increments the y position by the speed" do
        expect { player.move_forward }
          .to change { player.position }
          .to match_vector(0, speed)
      end
    end

    context "facing south east" do
      let(:angle) { π * 3/4.0 }

      it "increments the position by the unit vector in the direction of gaze" do
        new_position = Vector[unit_length_45_deg, unit_length_45_deg]

        expect { player.move_forward }
          .to change { player.position }
          .from([0, 0])
          .to match_vector(*new_position)
      end
    end
  end

  describe "#move_back" do
    context "facing south" do
      let(:angle) { π }
      let(:speed) { 3.0 }

      it "decrements the y position by the speed" do
        expect { player.move_back }
          .to change { player.position }
          .to match_vector(0, -speed)
      end
    end

    context "facing south east" do
      let(:angle) { π * 3/4.0 }

      it "decrements the position by the unit vector in the direction of gaze" do
        new_position = Vector[-unit_length_45_deg, -unit_length_45_deg]

        expect { player.move_back }
          .to change { player.position }
          .from([0, 0])
          .to match_vector(*new_position)
      end
    end
  end

  describe "#move_left" do
    context "facing south" do
      let(:angle) { π }
      let(:speed) { 4.0 }

      it "increments the x position by the speed" do
        expect { player.move_left }
          .to change { player.position }
          .to match_vector(speed, 0)
      end
    end

    context "facing south east" do
      let(:angle) { π * 3/4.0 }

      it "decrements the position by the unit vector in the direction of gaze" do
        new_position = Vector[unit_length_45_deg, -unit_length_45_deg]

        expect { player.move_left }
          .to change { player.position }
          .from([0, 0])
          .to match_vector(*new_position)
      end
    end
  end

  describe "#move_right" do
    context "facing south" do
      let(:angle) { π }
      let(:speed) { 5.0 }

      it "decrements the x position by the speed" do
        expect { player.move_right }
          .to change { player.position }
          .to match_vector(-speed, 0)
      end
    end

    context "facing south east" do
      let(:angle) { π * 3/4.0 }

      it "decrements the position by the unit vector in the direction of gaze" do
        new_position = Vector[-unit_length_45_deg, +unit_length_45_deg]

        expect { player.move_right }
          .to change { player.position }
          .from([0, 0])
          .to match_vector(*new_position)
      end
    end
  end

  describe "#move_back" do
    context "facing south" do
      let(:angle) { π }
      let(:speed) { 6.0 }

      it "decrements the y position by the speed" do
        expect { player.move_back }
          .to change { player.position }
          .to match_vector(0, -speed)
      end
    end

    context "facing south east" do
      let(:angle) { π * 3/4.0 }

      it "decrements the position by the unit vector in the direction of gaze" do
        new_position = Vector[-unit_length_45_deg, -unit_length_45_deg]

        expect { player.move_back }
          .to change { player.position }
          .from([0, 0])
          .to match_vector(*new_position)
      end
    end
  end
end
