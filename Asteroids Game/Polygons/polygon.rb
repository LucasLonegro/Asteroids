# frozen_string_literal: true
require_relative 'points_line'
require_relative 'point'

class Polygon
  include Comparable
  attr_accessor :lines, :points, :influence

  def initialize(*points)
    raise ArgumentError, 'Requires a set of points' unless points.reduce { |accum, e| accum && e.is_a?(Point) }
    @points = points.clone
    set_lines
    set_influence
  end
  def nearby?(point)
    return false unless point.is_a?(Point)
    ((@points[0].x_pos - point.x_pos) ** 2 + (@points[0].y_pos - point.y_pos) ** 2) < @inf2 * 1.44
  end
  def weak_nearby?(point)
    return false unless point.is_a?(Point)
    ((@points[0].x_pos - point.x_pos) ** 2 + (@points[0].y_pos - point.y_pos) ** 2) < @inf2 * 2.25
  end

  def draw
    #Circle.new(x:@points[0].x_pos, y:@points[0].y_pos, radius:@influence * 1.5, color:'navy')
    @lines.each { |e| e.draw }
    @points.each { |e| e.draw }
  end

  def <=>(other)
    @lines[0] <=> other.lines[0]
  end

  def ==(other)
    @lines == other.lines
  end

  def hash
    @lines.hash
  end

  def touches?(other)
    return false unless other.is_a?(Polygon)
    @lines.reduce(false) do |accum1, side|
      accum1 || other.lines.reduce(false) do |accum2, otherSide|
        accum2 || otherSide.intersects?(side)
      end
    end
  end

  def move_by(dx, dy)
    @points.each do |p|
      p.x_pos += dx
      p.y_pos += dy
    end
  end

  def scale_to(factor)
    raise ArgumentError, 'Requires a numeric' unless factor.is_a?(Numeric)
    @points.each do |p|
      p.x_pos = @points[0].x_pos + factor * (p.x_pos - @points[0].x_pos)
      p.y_pos = @points[0].y_pos + factor * (p.y_pos - @points[0].y_pos)
    end
    set_influence
  end

  def hit_by?(bullet)
    return false unless bullet.is_a?(Bullet) && (nearby?(bullet.location) || nearby?(bullet.next_location))
    next_location = bullet.next_location
    @lines.reduce(false) do |accum, side|
      accum || side.intersects?(PointsLine.new(bullet.location, next_location)) || side.intersects?(PointsLine.new(next_location, Point.new(next_location.x_pos - dx, next_location.y_pos - dy)))
    end
  end
  def to_s
    @points[0].to_s
  end
  alias_method :eql?, :==
  protected
  def set_lines
    temp1 = @points.clone
    temp1.push @points[0]
    temp1.shift
    temp2 = @points.zip temp1
    @lines = []
    temp2.each { |e| @lines.push(PointsLine.new(e[0], e[1])) }
    @lines.sort
  end
  def set_influence
    @influence = @points.reduce(0) do |accum, point|
      temp = @points[0].distance(point)
      accum > temp ? accum : temp
    end
    @inf2 = @influence**2
  end
end
