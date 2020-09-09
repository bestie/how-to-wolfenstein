class MutableVector
  def initialize(x, y)
    @x = x
    @y = y
  end

  attr_reader :x, :y

  def to_a
    [x, y]
  end

  def magnitude
    Math.sqrt(@x**2 + @y**2)
  end

  def ==(other)
    x == other.x && y == other.y
  end

  def +(other)
    @x += other.x
    @y += other.y
    self
  end

  def -(other)
    @x -= other.x
    @y -= other.y
    self
  end

  def *(n)
    @x *= n
    @y *= n
    self
  end

  def to_vector
    Vector[x, y]
  end
end
