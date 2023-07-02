# frozen_string_literal: true

require_relative '../Polygons/polygon'
require_relative '../Polygons/point'
require_relative '../Polygons/points_line'
require_relative '../bullet'
require 'ruby2d'
require_relative '../Polygons/moving_polygon'
require_relative '../Polygons/spinning_polygon'

class Default2 < Asteroid
  def initialize(velocity, direction, scale, point)
    raise ArgumentError, 'point must be a point, scale a numeric' unless point.is_a?(Point) && scale.is_a?(Numeric)
    @seed = Random.new
    rel_x = point.x_pos
    rel_y = point.y_pos
    p1 = Point.new(rel_x, rel_y)
    p2 = Point.new(rel_x + 25 * scale + random_displacement, rel_y - 25 * scale + random_displacement)
    p3 = Point.new(rel_x + 75 * scale + random_displacement, rel_y - 25 * scale + random_displacement)
    p4 = Point.new(rel_x + 100 * scale + random_displacement, rel_y + 0 * scale + random_displacement)
    p5 = Point.new(rel_x + 80 * scale + random_displacement, rel_y + 25 * scale + random_displacement)
    p6 = Point.new(rel_x + 100 * scale + random_displacement, rel_y + 50 * scale + random_displacement)
    p7 = Point.new(rel_x + 75 * scale + random_displacement, rel_y + 75 * scale + random_displacement)
    p8 = Point.new(rel_x + 50 * scale + random_displacement, rel_y + 50 * scale + random_displacement)
    p9 = Point.new(rel_x + 25 * scale + random_displacement, rel_y + 75 * scale + random_displacement)
    p10 = Point.new(rel_x + 0 * scale + random_displacement, rel_y + 50 * scale + random_displacement)
    super(velocity, direction, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10)
  end
  protected
  def random_displacement
    @seed.rand(26) - 12.5
  end
end
