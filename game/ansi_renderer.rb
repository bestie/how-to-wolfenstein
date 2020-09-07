class ANSIRenderer
  MAX_DEPTH = 10.0
  GRADIENT = ".-=+*#@%"
  WALL_GRADIENT = GRADIENT.chars.map { |c| ANSI.red(c) } +
    GRADIENT.chars.reverse.map { |c| ANSI.black_on_red(c) } +
    [ANSI.black_on_red(" ")]

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
      distance = distance_to_wall(position, angle)

      render_column(distance)
    }

    scene.transpose
  end

  private

  def field_of_view_range
    half_field = field_of_view / 2.0
    column_arc_width =  field_of_view / (canvas_width - 1).to_f
    leftmost_angle = (angle - half_field)
    rightmost_angle = (angle + half_field)

    (leftmost_angle..rightmost_angle).step(column_arc_width)
  end

  def render_column(distance)
    ceiling_projection = ceiling_projection(distance)

    ceiling_char_size  = (ceiling_projection * canvas_height).round
    floor_char_size = ceiling_char_size
    wall_char_size = canvas_height - ceiling_char_size - floor_char_size

    [" "] * ceiling_char_size +
      [wall_char(distance)] * wall_char_size +
      ["."] * floor_char_size
  end

  def ceiling_projection(distance)
    (1 - wall_projection(distance)) / 2.0
  end

  def wall_projection(distance)
    non_zero_distance = [0.1, distance].max

    [
      (2.0 / non_zero_distance),
      1.0,
    ].min
  end

  def distance_to_wall(position, angle)
    tracer.distance_to_wall(map: map, from: position, angle: angle)
  end

  def wall_char(distance)
    return " " if distance > MAX_DEPTH

    intensity = 1.0/( (distance/(MAX_DEPTH/2.0))**2 + 1 )
    shade_index = (intensity * WALL_GRADIENT.length).floor - 1
    WALL_GRADIENT.fetch(shade_index)
  end
end
