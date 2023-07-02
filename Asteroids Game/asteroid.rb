# frozen_string_literal: true
require_relative 'Polygons/polygon'
require_relative 'Polygons/point'
require_relative 'Polygons/points_line'
require_relative 'bullet'
require 'ruby2d'
require_relative 'Polygons/moving_polygon'
require_relative 'Polygons/spinning_polygon'

class Asteroid < SpinningPolygon
  def initialize(velocity, direction, *points)
    super(velocity, direction, points[0], *points)
    @first_velocity = velocity
  end

  def break(size_factor, separating_angle)
    raise ArgumentError, 'factors are coefficients between 0 and 1, force is a numeric' unless size_factor.is_a?(Numeric) && separating_angle.is_a?(Numeric) && size_factor.between?(0, 1)
    other = self.clone
    other.points = []
    @points.each { |p| other.points.push p.clone }
    other.center_point = other.points[0]
    other.set_lines
    other.scale_to size_factor ** 0.5
    self.scale_to (1 - size_factor) ** 0.5
    @direction += separating_angle
    other.direction -= separating_angle
    other.rotate_by(Random.rand(11) / 20.0 * Math::PI)
    dv = Random.rand(11) / 5.0 + 0.9
    other.velocity *= dv if @velocity <= (@first_velocity * 1.5) || dv <= 1.0
    other
  end
end
