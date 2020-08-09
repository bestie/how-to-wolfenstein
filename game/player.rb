require "vector"

class Player
  def initialize(position: Vector[0.0, 0.0], angle: 0.0, speed: 1.0, turn_rate: 0.2)
    @position = position
    @angle = angle
    @speed = speed
    @turn_rate = turn_rate
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

  def turn_left
    @angle -= @turn_rate
  end

  def turn_right
    @angle += @turn_rate
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
