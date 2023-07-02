# frozen_string_literal: true
require_relative '../Polygons/polygon'
require_relative '../Polygons/point'
require_relative '../Polygons/points_line'
require_relative '../bullet'
require 'ruby2d'
require_relative '../Polygons/moving_polygon'
require_relative '../asteroid'
require_relative '../Polygons/spinning_polygon'
require_relative 'spaceship'
require_relative 'drag_spaceship'

class AcceleratingSpaceship < DragSpaceship
  def initialize(thrust_power, size, velocity, drag, base_point, color)
    super(thrust_power, size, velocity, drag, base_point, color)
  end

  def thrust
    vel_x = @velocity * Math.cos(@direction)
    vel_y = @velocity * Math.sin(@direction)
    vel_x += @thrust_power * Math.cos(@angle)
    vel_y += @thrust_power * Math.sin(@angle)
    @velocity = (vel_x ** 2 + vel_y ** 2) ** 0.5
    if @velocity.zero?
      @direction = 0
    else
      @direction = Math.acos(vel_x/@velocity)
      @direction *= -1 unless vel_y.positive?
    end
  end
end
