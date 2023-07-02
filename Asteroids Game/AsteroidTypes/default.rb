# frozen_string_literal: true

require_relative '../Polygons/polygon'
require_relative '../Polygons/point'
require_relative '../Polygons/points_line'
require_relative '../bullet'
require 'ruby2d'
require_relative '../Polygons/moving_polygon'
require_relative '../Polygons/spinning_polygon'

class Default < Asteroid
  def initialize(velocity, direction, scale, point)
    raise ArgumentError, 'point must be a point, scale a numeric' unless point.is_a?(Point) && scale.is_a?(Numeric)
    rel_x = point.x_pos
    rel_y = point.y_pos
    p1 = Point.new(rel_x, rel_y)
    p2 = Point.new(rel_x + 25 * scale, rel_y - 25 * scale)
    p3 = Point.new(rel_x + 75 * scale, rel_y - 25 * scale)
    p4 = Point.new(rel_x + 100 * scale, rel_y + 0 * scale)
    p5 = Point.new(rel_x + 80 * scale, rel_y + 25 * scale)
    p6 = Point.new(rel_x + 100 * scale, rel_y + 50 * scale)
    p7 = Point.new(rel_x + 75 * scale, rel_y + 75 * scale)
    p8 = Point.new(rel_x + 50 * scale, rel_y + 50 * scale)
    p9 = Point.new(rel_x + 25 * scale, rel_y + 75 * scale)
    p10 = Point.new(rel_x + 0 * scale, rel_y + 50 * scale)
    super(velocity, direction, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10)
  end
end

