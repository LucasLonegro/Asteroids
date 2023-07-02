# frozen_string_literal: true
require_relative '../Polygons/polygon'
require_relative '../Polygons/point'
require_relative '../Polygons/points_line'
require_relative '../bullet'
require 'ruby2d'
require_relative '../Polygons/moving_polygon'
require_relative '../asteroid'
require_relative '../Polygons/spinning_polygon'

class Spaceship < SpinningPolygon
  attr_writer :live
  attr_accessor :angle

  def initialize(size, velocity, base_point, color)
    raise ArgumentError, 'Requires two numerics, a point, and a color recognized by ruby2d' unless size.is_a?(Numeric) && base_point.is_a?(Point) && color.is_a?(String)
    @size = size
    @aperture = Math::PI / 8
    direction = Math::PI / 2
    super(velocity, direction, base_point, Point.new(base_point.x_pos, base_point.y_pos + @size), Point.new(base_point.x_pos - @size / 3, base_point.y_pos), Point.new(base_point.x_pos + @size / 3, base_point.y_pos))
    @angle = @direction
    @live = true
    @color = color
  end

=begin
  def thrust
    puts "d: #{@direction}"
    puts "a: #{@angle}"
    vel_x = dx + @thrust_power * Math.cos(@angle)
    vel_y = dy + @thrust_power * Math.sin(@angle)
    @velocity = (vel_x**2 + vel_y**2)**0.5
    @direction = Math.cos(vel_x / @velocity) * (vel_y >= 0 ? 1:-1)
  end
=end
  def thrust
    @direction = @angle
  end

  def fire
    Bullet.new(24, @angle, @points[0].clone)
  end

  def live?
    @live
  end

  def move
    super if @live
  end

  def rotate_by(angle)
    super(angle) if @live
  end

  def draw_death
    Circle.new(x: @points[0].x_pos, y: @points[0].y_pos, radius: @size / 2, color: 'red')
  end

  def draw
    Triangle.new(x1: @points[0].x_pos, x2: @points[1].x_pos, x3: @points[2].x_pos, y1: @points[0].y_pos, y2: @points[1].y_pos, y3: @points[2].y_pos, color: @color)
    draw_death unless @live
    super
  end

  def auto_turn(point, rate)
    raise ArgumentError, 'Requires a point and a numeric' unless point.is_a?(Point) && rate.is_a?(Numeric)
    da = @angle - (@points[0].angle point)
    if da.abs > 0.1
      if da.between?(-2 * Math::PI, -Math::PI) || da.between?(0, Math::PI)
        rotate_by rate
      else
        rotate_by -rate
      end
    end
  end
end
