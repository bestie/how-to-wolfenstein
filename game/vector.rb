class Vector
  def self.from_angle(angle)
    self.new(
      Math.sin(angle),
      -Math.cos(angle),
    )
  end

  def self.[](x, y)
    new(x, y)
  end

  def initialize(x, y)
    @x = x
    @y = y
  end

  attr_reader :x, :y

  def +(other)
    self.class.new(
      x + other.x,
      y + other.y,
    )
  end

  def -(other)
    self.class.new(
      x - other.x,
      y - other.y,
    )
  end

  def *(magnitude)
    self.class.new(
      x * magnitude,
      y * magnitude,
    )
  end

  def magnitude
    @magnitude ||= Math.sqrt(x**2 + y**2)
  end

  def ==(other)
    (x - other.x).abs < 10**-6 && (y - other.y).abs < 10**-6
  end

  def to_a
    [x,y]
  end

  def to_s
    inspect
  end

  def to_mut
    MutableVector.new(x,y)
  end
end
