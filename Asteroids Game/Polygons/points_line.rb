# frozen_string_literal: true
require 'ruby2d'
require_relative 'point'

class PointsLine
  attr_reader :p1, :p2
  include Comparable

  def initialize(p1, p2)
    raise ArgumentError, 'Requires two points' unless p1.is_a?(Point) && p2.is_a?(Point)
    @p1 = p1 > p2 ? p1 : p2
    @p2 = p1 > p2 ? p2 : p1
  end

  def draw
    Line.new(x1: @p1.x_pos, y1: @p1.y_pos, x2: @p2.x_pos, y2: @p2.y_pos, width: 2, color: 'white')
  end

  def ==(other)
    return false unless other.is_a?(PointsLine)
    [@p1, @p2] == [other.p1, other.p2]
  end

  def hash
    [@p1, @p2].hash
  end

  alias_method :eql?, :==

  def <=>(other)
    @p1 <=> @p2
  end

  def intersects?(other)
    return false unless other.is_a?(PointsLine)
    o1 = orientation(@p1,@p2,other.p1)
    o2 = orientation(@p1,@p2,other.p2)
    o3 = orientation(other.p1,other.p2,@p1)
    o4 = orientation(other.p1,other.p2,@p2)
    (o1 != o2 && o3 != o4) || (o1 == 0 && on_segment(@p1,other.p1,@p2)) || (o2 == 0 && on_segment(@p1,other.p2,@p2)) || (o3 == 0 && on_segment(other.p1,@p1,other.p2)) || (o4 == 0 && on_segment(other.p1, @p2, other.p2))
  end

  private

  def on_segment(p1, p2, p3)
    return false unless p1.is_a?(Point) && p2.is_a?(Point) && p3.is_a?(Point)
    p2.x_pos <= [p1.x_pos, p3.x_pos].max && p2.x_pos >= [p1.x_pos, p3.x_pos].min && p2.y_pos <= [p1.y_pos, p3.y_pos].max && p2.y_pos >= [p1.y_pos, p3.y_pos].min
  end

  def orientation(p1, p2, p3)
    raise ArgumentError, 'Receives points' unless p1.is_a?(Point) && p2.is_a?(Point) && p3.is_a?(Point)
    val = (p2.y_pos - p1.y_pos) * (p3.x_pos - p2.x_pos) - (p2.x_pos - p1.x_pos) * (p3.y_pos - p2.y_pos)
    if val.zero?
      0
    else
      val > 0 ? 1 : 2
    end
  end
end
