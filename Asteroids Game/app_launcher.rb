# frozen_string_literal: true
require_relative 'Polygons/point'
require_relative 'Polygons/points_line'
require_relative 'Polygons/polygon'
require_relative 'Polygons/moving_polygon'
require_relative 'Polygons/spinning_polygon'
require_relative 'Spaceship/spaceship'
require_relative 'Spaceship/drag_spaceship'
require_relative 'Spaceship/accelerating_spaceship'
require_relative 'bullet'
require_relative 'asteroid'
require_relative 'AsteroidTypes/default'
require_relative 'world'
require 'ruby2d'

set background: 'black'
set fps_cap: 30

GRID_SIZE = 20 # grid size is 20 pixels
# Set these at whatever you want, the game won't break
set width: Window.width * 2.0
set height: Window.height * 1.6


# for default window size of 480px * 640px, width is 32 (640/20) and height is 24 (480/20) at grid size = 20 pixels
GRID_WIDTH = Window.width / GRID_SIZE
GRID_HEIGHT = Window.height / GRID_SIZE
CENTER_X = Window.width / 2
CENTER_Y = Window.height / 2
MOUSE_DEAD_ANGLE = 0.1

# Press q to exit. Press + to add spaceships (You might have to modify this one, all keyboards are different).
# Spaceship one uses wasd and l-shift. Spaceship two uses arrows and space. Spaceship three follows the mouse around and click-to-shoot (spaceship three is op, I have limited its rotation speed to counteract this).
# World can handle infinite spaceships (fighters are literally game-controlled spaceships), you just have to figure out how to control them through user-input.



world = World.new(Window::fps_cap, Window.width, Window.height)
@rotation = 0
@thrust = false
@fire = false
@movements = [[false, false, 0], [false, false, 0], [false, true, 0]]
@spaceship_count = 1
update do
  on :key_held do |event|
    if ['a', 'A'].include? event.key
      @movements[0][2] = 1
    elsif event.key == 'left'
      @movements[1][2] = 1
    elsif ['d', 'D'].include? event.key
      @movements[0][2] = -1
    elsif event.key == 'right'
      @movements[1][2] = -1
    elsif ['w', 'W'].include? event.key
      @movements[0][1] = true
    elsif event.key == 'up'
      @movements[1][1] = true
    elsif event.key == 'left shift'
      @movements[0][0] = true
    elsif event.key == 'space'
      @movements[1][0] = true
    elsif ['keypad +', ']'].include?(event.key) && @spaceship_count <= 2
      @spaceship_count += 1
      world.add_spaceship
    elsif ['r', 'R'].include? event.key
      world.restart
    end
    if event.key == 'q' or event.key == 'Q' # quitting game
      exit
    end
  end
  on :key_up do |event|
    if ['a', 'A', 'd', 'D'].include? event.key
      @movements[0][2] = 0
    elsif ['left', 'right'].include? event.key
      @movements[1][2] = 0
    elsif ['w', 'W'].include? event.key
      @movements[0][1] = false
    elsif event.key == 'up'
      @movements[1][1] = false
    elsif event.key == 'left shift'
      @movements[0][0] = false
    elsif event.key == 'space'
      @movements[1][0] = false
    end
  end

  on :mouse_down do |event|
    if :left
      @movements[2][0] = true
    end
  end
  on :mouse_up do |event|
    if :left
      @movements[2][0] = false
    end
  end
  mouse = Point.new(Window::mouse_x, Window::mouse_y)
  if @spaceship_count >= 3
    ship = world.spaceships[2]
    da = ship.angle - (ship.points[0].angle mouse)
    if da.abs > MOUSE_DEAD_ANGLE
      if da.between?(-2 * Math::PI, -Math::PI) || da.between?(0, Math::PI)
        @movements[2][2] = 1
      else
        @movements[2][2] = -1
      end
    else
      @movements[2][2] = 0
    end
  end

  unless world.game_over?
    clear
    world.update(@movements[0], @movements[1], @movements[2])
  end

end

show

