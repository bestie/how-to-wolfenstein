require "spec_helper"

RSpec.describe Player do
  subject(:player) {
    Player.new(
      position: origin,
      speed: speed,
      angle: angle,
      turn_rate: turn_rate,
    )
  }

  let(:speed) { 1.0 }
  let(:origin) { Vector[0, 0] }
  let(:angle) { 0 }
  let(:turn_rate) { π / 8.0 }
  let(:unit_length_45_deg) { Math.sqrt(0.5) }

  let(:passing_check) { ->(_) { true } }
  let(:failing_check) { ->(_) { false } }

  describe "#walk_forward" do
    context "facing south" do
      let(:angle) { π }
      let(:speed) { 2.0 }

      it "increments the y position by the speed" do
        expect { player.walk_forward }
          .to change { player.position }
          .to match_vector(0, speed)
      end
    end

    context "facing south east" do
      let(:angle) { π * 3/4.0 }

      it "increments the position by the unit vector in the direction of gaze" do
        new_position = Vector[unit_length_45_deg, unit_length_45_deg]

        expect { player.walk_forward }
          .to change { player.position }
          .from([0, 0])
          .to match_vector(*new_position)
      end
    end

    context "when check passes" do
      it "does not update the position" do
        expect { player.walk_forward(&passing_check) }
          .to change { player.position }
      end
    end

    context "when check fails" do
      it "does not update the position" do
        expect { player.walk_forward(&failing_check) }
          .not_to change { player.position }
      end
    end

    it "passes the new position to the check function" do
      new_position = Vector[0.0, -1.0]
      captured_args = nil
      check_func = ->(*args) { captured_args = args }

      player.walk_forward(&check_func)

      expect(captured_args).to eq([new_position])
    end
  end

  describe "#walk_back" do
    context "facing south" do
      let(:angle) { π }
      let(:speed) { 3.0 }

      it "decrements the y position by the speed" do
        expect { player.walk_back }
          .to change { player.position }
          .to match_vector(0, -speed)
      end
    end

    context "facing south east" do
      let(:angle) { π * 3/4.0 }

      it "decrements the position by the unit vector in the direction of gaze" do
        new_position = Vector[-unit_length_45_deg, -unit_length_45_deg]

        expect { player.walk_back }
          .to change { player.position }
          .from([0, 0])
          .to match_vector(*new_position)
      end
    end

    context "when check passes" do
      it "does not update the position" do
        expect { player.walk_back(&passing_check) }
          .to change { player.position }
      end
    end

    context "when check fails" do
      it "does not update the position" do
        expect { player.walk_back(&failing_check) }
          .not_to change { player.position }
      end
    end
  end

  describe "#strafe_left" do
    context "facing south" do
      let(:angle) { π }
      let(:speed) { 4.0 }

      it "increments the x position by the speed" do
        expect { player.strafe_left }
          .to change { player.position }
          .to match_vector(speed, 0)
      end
    end

    context "facing south east" do
      let(:angle) { π * 3/4.0 }

      it "decrements the position by the unit vector in the direction of gaze" do
        new_position = Vector[unit_length_45_deg, -unit_length_45_deg]

        expect { player.strafe_left }
          .to change { player.position }
          .from([0, 0])
          .to match_vector(*new_position)
      end
    end

    context "when check passes" do
      it "does not update the position" do
        expect { player.strafe_left(&passing_check) }
          .to change { player.position }
      end
    end

    context "when check fails" do
      it "does not update the position" do
        expect { player.strafe_left(&failing_check) }
          .not_to change { player.position }
      end
    end
  end

  describe "#strafe_right" do
    context "facing south" do
      let(:angle) { π }
      let(:speed) { 5.0 }

      it "decrements the x position by the speed" do
        expect { player.strafe_right }
          .to change { player.position }
          .to match_vector(-speed, 0)
      end
    end

    context "facing south east" do
      let(:angle) { π * 3/4.0 }

      it "decrements the position by the unit vector in the direction of gaze" do
        new_position = Vector[-unit_length_45_deg, +unit_length_45_deg]

        expect { player.strafe_right }
          .to change { player.position }
          .from([0, 0])
          .to match_vector(*new_position)
      end
    end

    context "when check passes" do
      it "does not update the position" do
        expect { player.strafe_right(&passing_check) }
          .to change { player.position }
      end
    end

    context "when check fails" do
      it "does not update the position" do
        expect { player.strafe_right(&failing_check) }
          .not_to change { player.position }
      end
    end
  end

  describe "#walk_back" do
    context "facing south" do
      let(:angle) { π }
      let(:speed) { 6.0 }

      it "decrements the y position by the speed" do
        expect { player.walk_back }
          .to change { player.position }
          .to match_vector(0, -speed)
      end
    end

    context "facing south east" do
      let(:angle) { π * 3/4.0 }

      it "decrements the position by the unit vector in the direction of gaze" do
        new_position = Vector[-unit_length_45_deg, -unit_length_45_deg]

        expect { player.walk_back }
          .to change { player.position }
          .from([0, 0])
          .to match_vector(*new_position)
      end
    end

    context "when check passes" do
      it "does not update the position" do
        expect { player.walk_back(&passing_check) }
          .to change { player.position }
      end
    end

    context "when check fails" do
      it "does not update the position" do
        expect { player.walk_back(&failing_check) }
          .not_to change { player.position }
      end
    end
  end

  describe "#turn_left" do
    let(:angle) { π }

    it "decreases the angle by the turn rate" do
      expect { player.turn_left }
        .to change { player.angle }
        .by(-turn_rate)
    end

    context "when the angle becomes less than 0" do
      let(:angle) { 1/16.0 * π }

      it "wraps the angle around 2π" do
        player.turn_left
        expect(player.angle).to be_within(10**-6).of (31/16.0 * π)
      end
    end
  end

  describe "#turn_right" do
    let(:angle) { π }

    it "increases the angle by the turn rate" do
      expect { player.turn_right }
        .to change { player.angle }
        .by(turn_rate)
    end

    context "when the angle becomes more than 2π" do
      let(:angle) { 2 * π }

      it "wraps the angle around 2π" do
        player.turn_right
        expect(player.angle).to be_within(10**-6).of (turn_rate)
      end
    end
  end
end
