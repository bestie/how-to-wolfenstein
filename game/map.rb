class Map
  PLAYER = "O"
  START_POSITION = "X"

  class << self
    def from_string(string)
      new(string.strip.split("\n").map(&:chars))
    end
  end

  def initialize(rows)
    @rows = rows
  end

  attr_reader :rows, :player_start_position

  def with_player(position)
    x = position.x.floor
    y = position.y.floor

    new_row = rows[y].clone
    new_row[x] = PLAYER

    self.class.new(rows[0..y-1] + [new_row] + rows[y+1..-1])
  end

  def player_start_position
    row = rows.detect { |row| row.include?(START_POSITION) }
    x = row.index(START_POSITION) + 0.5
    y = rows.index(row) + 0.5

    [x, y]
  end
end
