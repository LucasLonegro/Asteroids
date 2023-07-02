# frozen_string_literal: true
require 'ruby2d'

class Point
  attr_accessor :x_pos, :y_pos
  include Comparable

  def initialize(x, y)
    @x_pos = x
    @y_pos = y
  end

  def draw
    Circle.new(x: @x_pos, y: @y_pos, radius: 1, color: 'white')
  end

  def ==(other)
    return false unless other.is_a?(Point)
    [@x_pos, @y_pos] == [other.x_pos, other.y_pos]
  end

  alias_method :eql?, :==

  def hash
    [@x_pos, @y_pos].hash
  end

  def <=>(other)
    @x_pos <=> other.x_pos
  end

  def distance(other)
    raise ArgumentError, 'Not a point' unless other.is_a?(Point)
    ((@x_pos - other.x_pos) ** 2 + (@y_pos - other.y_pos) ** 2) ** 0.5
  end

  def angle(other)
    raise ArgumentError, 'Not a point' unless other.is_a?(Point)
    dx = other.x_pos - @x_pos
    dy = other.y_pos - @y_pos
    if dy.positive?
      Math.acos(dx / self.distance(other))
    else
      Math.acos(-dx / self.distance(other)) + Math::PI
    end
  end

  def rotate_about(other, angle)
    raise ArgumentError, 'Not a point' unless other.is_a?(Point)
    raise ArgumentError, 'Not an angle' unless angle.is_a?(Numeric)
    rel_x = other.x_pos - @x_pos
    rel_y = other.y_pos - @y_pos
    @x_pos = @x_pos + (rel_x - (rel_x * Math.cos(angle) + rel_y * Math.sin(angle)))
    @y_pos = @y_pos + (rel_y - (-rel_x * Math.sin(angle) + rel_y * Math.cos(angle)))
  end

  def to_s
    "<#{@x_pos},#{@y_pos}>"
  end
end
