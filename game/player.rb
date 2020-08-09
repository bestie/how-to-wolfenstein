require "vector"

class Player
  def initialize(position: Vector[0.0, 0.0], angle: 0.0, speed: 1.0)
    @position = position
    @angle = angle
    @speed = speed
  end

  attr_accessor :position, :angle, :speed

  def walk_forward
    @position = @position + (look_unit_vector * speed)
  end

  def strafe_left
    @position = @position + (left_unit_vector * speed)
  end

  def walk_back
    @position = @position - (look_unit_vector * speed)
  end

  def strafe_right
    @position = @position + (right_unit_vector * speed)
  end

  private

  def right_unit_vector
    Vector.from_angle(angle + π / 2.0)
  end

  def left_unit_vector
    Vector.from_angle(angle - π / 2.0)
  end

  def look_unit_vector
    Vector.from_angle(angle)
  end
end
