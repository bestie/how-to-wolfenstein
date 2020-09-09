class ANSIRenderer
  MAX_DEPTH = 10.0
  GRADIENT = ".-=+*#@%".chars
  WALL_GRADIENT = (
    GRADIENT.map { |c| ANSI.red(c) } +
    GRADIENT.reverse.map { |c| ANSI.black_on_red(c) } +
    [ANSI.black_on_red(" ")]
  )
  GOAL_GRADIENT = (
    GRADIENT.map { |c| ANSI.green(c) } +
    GRADIENT.reverse.map { |c| ANSI.black_on_green(c) } +
    [ANSI.black_on_green(" ")]
  )

  def self.to_callable_with(tracer:)
    ->(**args) { self.new(**args.merge(tracer: tracer)).call }
  end

  def initialize(map:, tracer:, field_of_view:, position:, angle:, canvas_width:, canvas_height:)
    @map = map
    @tracer = tracer
    @field_of_view = field_of_view
    @position = position
    @angle = angle
    @canvas_width = canvas_width
    @canvas_height = canvas_height
  end

  attr_reader :map, :tracer, :field_of_view, :position, :angle, :canvas_width, :canvas_height
  private     :map, :tracer, :field_of_view, :position, :angle, :canvas_width, :canvas_height

  def call
    scene = field_of_view_range.map { |angle|
      wall_pos = tracer.wall_position(map: map, from: position, angle: angle)
      vector_to_wall = wall_pos - position

      render_column(vector_to_wall, wall_pos)
    }

    scene.transpose
  end

  private

  def render_column(vector_to_wall, wall_position)
    distance = vector_to_wall.magnitude
    ceiling_projection = ceiling_projection(distance)

    ceiling_char_size  = (ceiling_projection * canvas_height).round
    floor_char_size = ceiling_char_size
    wall_char_size = canvas_height - ceiling_char_size - floor_char_size

    [" "] * ceiling_char_size +
      [wall_char(distance, wall_position)] * wall_char_size +
      ["."] * floor_char_size
  end

  def field_of_view_range
    half_field = field_of_view / 2.0
    column_arc_width =  field_of_view / (canvas_width - 1).to_f
    leftmost_angle = (angle - half_field)
    rightmost_angle = (angle + half_field)

    (leftmost_angle..rightmost_angle).step(column_arc_width)
  end

  def ceiling_projection(distance)
    (1 - wall_projection(distance)) / 2.0
  end

  def wall_projection(distance)
    non_zero_distance = [2.0, distance].max

    2.0 / non_zero_distance
  end

  def wall_char(distance, wall_position)
    return " " if distance > MAX_DEPTH

    intensity = 1.0/( (distance/(MAX_DEPTH/2.0) + 1.01)**2)

    if map.goal?(wall_position)
      shade_index = (intensity * GOAL_GRADIENT.length).floor
      GOAL_GRADIENT.fetch(shade_index)
    else
      shade_index = (intensity * WALL_GRADIENT.length).floor
      WALL_GRADIENT.fetch(shade_index)
    end
  end
end
