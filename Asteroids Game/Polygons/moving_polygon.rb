# frozen_string_literal: true
require_relative 'polygon'
require_relative 'point'
require_relative 'points_line'
require_relative '../bullet'
require 'ruby2d'

class MovingPolygon < Polygon
  attr_accessor :velocity, :direction
  def initialize(velocity, direction, *points)
    @velocity = velocity
    @direction = direction % (Math::PI * 2)
    super(*points)
  end

  def move
    @points.each do |p|
      p.x_pos += dx
      p.y_pos += dy
    end
  end

  protected

  def dx
    @velocity * Math.cos(@direction)
  end

  def dy
    @velocity * Math.sin(@direction)
  end
end
