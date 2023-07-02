# frozen_string_literal: true
require_relative 'polygon'
require_relative 'point'
require_relative 'points_line'
require_relative '../bullet'
require 'ruby2d'
require_relative 'moving_polygon'

class SpinningPolygon < MovingPolygon
  attr_accessor :angle, :center_point

  def initialize(velocity, direction, center_point, *points)
    raise ArgumentError, 'Not a point' unless center_point.is_a?(Point)
    @center_point = center_point
    @angle = 0
    super(velocity, direction, *points)
  end

  def move
    super
    unless @points.include? @center_point
      @center_point.x_pos += dx
      @center_point.y_pos += dy
    end
  end

  def rotate_by(angle)
    @angle = (@angle - angle) % (Math::PI * 2)
    @points.each { |p| p.rotate_about(@center_point, angle) }
  end

  def scale_to(factor)
    super
    @center_point.x_pos = @points[0].x_pos + factor * (@center_point.x_pos - @points[0].x_pos)
    @center_point.y_pos = @points[0].y_pos + factor * (@center_point.y_pos - @points[0].y_pos)
  end

  def move_by(dx, dy)
    super
    unless @points.include? @center_point
      @center_point.x_pos += dx
      @center_point.y_pos += dy
    end
  end
end
