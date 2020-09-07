class Map
  PLAYER = "O"
  START_POSITION = "X"
  GOAL = "G"
  WALL = "#"

  module Arrows
    NORTH = "↑"
    EAST = "→"
    SOUTH = "↓"
    WEST = "←"
  end

  class << self
    def from_string(string)
      new(string.strip.split("\n").map(&:chars))
    end
  end

  def initialize(rows)
    @rows = rows
    @max_y = rows.length
    @max_x = rows[0].length
  end

  attr_reader :rows, :player_start_position

  def in_bounds?(position)
    (
      position.x > 0 &&
      position.y > 0 &&
      position.x < @max_x &&
      position.y < @max_y
    ) && (goal?(position) || !wall?(position))
  end

  def overlay_player(position, angle)
    x = position.x.floor
    y = position.y.floor

    new_row = rows[y].clone
    new_row[x] = angle_to_arrow(angle)

    self.class.new(rows[0..y-1] + [new_row] + rows[y+1..-1])
  end

  def player_start_position
    row = rows.detect { |row| row.include?(START_POSITION) }
    x = row.index(START_POSITION) + 0.5
    y = rows.index(row) + 0.5

    Vector[x, y]
  end

  def goal?(position)
    position.to_a.map(&:floor) == goal_position.to_a
  end

  def wall?(position)
    x,y = position.to_a.map(&:floor)
    rows[y][x] == WALL || rows[y][x] == GOAL
  end

  private

  def goal_position
    row = rows.detect { |row| row.include?(GOAL) }
    x = row.index(GOAL)
    y = rows.index(row)

    Vector[x, y]
  end

  def angle_to_arrow(angle)
    if (0.0..π/4.0).cover?(angle)
      Arrows::NORTH
    elsif (π/4.0..3*π/4.0).cover?(angle)
      Arrows::EAST
    elsif (3*π/4.0..5*π/4.0).cover?(angle)
      Arrows::SOUTH
    elsif (5*π/4.0..7.0*π/4.0).cover?(angle)
      Arrows::WEST
    elsif (7*π/4.0..2.0*π).cover?(angle)
      Arrows::NORTH
    end
  end
end
