class MutableVector
  def initialize(x, y)
    @x = x
    @y = y
  end

  attr_reader :x, :y

  def to_a
    [x, y]
  end

  def [](n)
    if n == 0
      x
    elsif n == 1
      y
    else
      raise IndexError.new("#{self.inspect} has no index #{n}")
    end
  end

  def magnitude
    Math.sqrt(@x**2 + @y**2)
  end

  def ==(other)
    x == other[0] && y == other[1]
  end

  def +(other)
    @x += other[0]
    @y += other[1]
    self
  end

  def -(other)
    @x -= other[0]
    @y -= other[1]
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
