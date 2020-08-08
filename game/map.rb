class Map
  class << self
    def from_string(string)
      new(string.strip.split("\n").map(&:chars))
    end

    private :new
  end

  def initialize(level)
    @level = level
  end

  attr_reader :level
  private     :level

  def rows
    @level
  end
end
