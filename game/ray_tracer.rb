class RayTracer
  RESOLUTION = 0.05

  def vector_to_wall(map:, from:, angle:)
    wall_pos = wall_position(map: map, from: from, angle: angle)

    wall_pos - from
  end

  def wall_position(map:, from:, angle:)
    ray = from.to_mut
    unit_vector = Vector.from_angle(angle)
    increment = unit_vector * RESOLUTION

    until map.wall?(ray)
      ray = ray + increment
    end

    ray.to_vector
  end
end
