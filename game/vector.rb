require "matrix"

Vector.class_eval do
  def self.from_angle(angle)
    Vector[Math.sin(angle), -Math.cos(angle)]
  end

  def x
    self[0]
  end

  def y
    self[1]
  end

  def to_mut
    MutableVector.new(x, y)
  end
end
