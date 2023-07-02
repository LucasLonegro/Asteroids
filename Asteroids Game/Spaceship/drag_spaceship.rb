# frozen_string_literal: true
require 'ruby2d'
require_relative '../Polygons/polygon'
require_relative '../Polygons/point'
require_relative '../Polygons/points_line'
require_relative '../bullet'
require 'ruby2d'
require_relative '../Polygons/moving_polygon'
require_relative '../asteroid'
require_relative '../Polygons/spinning_polygon'
require_relative 'spaceship'
class DragSpaceship < Spaceship
  def initialize(thrust_power, size,velocity,drag, base_point,color)
    raise ArgumentError 'drag is a coefficient between 0 and 1' unless drag.is_a?(Numeric) && drag.between?(0,1)
    super(size,velocity, base_point, color)
    @thrust_power = thrust_power
    @drag = drag
  end
  def move
    super
    @velocity =@velocity - @velocity*@drag
  end

  def thrust
    super
    @velocity = @thrust_power
  end
end
