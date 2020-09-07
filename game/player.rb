require "vector"

class Player
  def initialize(position: Vector[0.0, 0.0], angle: 0.0, speed: 0.1, turn_rate: π/8.0)
    @position = position
    @angle = angle
    @speed = speed
    @turn_rate = turn_rate
  end

  attr_accessor :position, :angle, :speed

  def walk_forward(&block)
    new_position = @position + (look_unit_vector * speed)
    update_position(new_position, block)
  end

  def walk_back(&block)
    new_position = @position - (look_unit_vector * speed)
    update_position(new_position, block)
  end

  def strafe_left(&block)
    new_position = @position + (left_unit_vector * speed)
    update_position(new_position, block)
  end

  def strafe_right(&block)
    new_position = @position + (right_unit_vector * speed)
    update_position(new_position, block)
  end

  def turn_left
    @angle = (@angle - @turn_rate) % (2*π)
  end

  def turn_right
    @angle = (@angle + @turn_rate) % (2*π)
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

  private

  def update_position(new_position, check)
    if check
      if check.call(new_position)
        @position = new_position
      end
    else
      @position = new_position
    end
  end
end
