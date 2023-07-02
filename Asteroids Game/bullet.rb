# frozen_string_literal: true
require_relative 'Polygons/point'
class Bullet
  attr_reader :velocity, :direction, :location, :cooldown
  def initialize(velocity, direction, point)
    raise ArgumentError, 'Requires two numbers and a point' unless velocity.is_a?(Numeric) && direction.is_a?(Numeric) && point.is_a?(Point)
    @velocity = velocity
    @direction = direction % (Math::PI * 2)
    @location = point
    @cooldown = 1
  end
  def move
    @location.x_pos += dx
    @location.y_pos += dy
    @cooldown = 0 if @cooldown == 1
  end
  def next_location
    Point.new(@location.x_pos + dx,@location.y_pos + dy)
  end
  def draw
    @location.draw
  end
  private
  def dx
    @velocity * Math.cos(@direction)
  end
  def dy
    @velocity * Math.sin(@direction)
  end
end
