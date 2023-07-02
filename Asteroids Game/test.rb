# frozen_string_literal: true
require 'ruby2d'
require_relative 'Polygons/point'
require_relative 'Polygons/points_line'
require_relative 'Polygons/polygon'
require_relative 'asteroid'
require_relative 'bullet'
require_relative 'Polygons/moving_polygon'
require_relative 'Spaceship/spaceship'
require_relative 'Spaceship/drag_spaceship'
require_relative 'Spaceship/accelerating_spaceship'
set background: 'black'
set fps_cap: 30

GRID_SIZE = 20 # grid size is 20 pixels
set width: Window.width * 1.6
set height: Window.height * 1.6
# for default window size of 480px * 640px, width is 32 (640/20) and height is 24 (480/20) at grid size = 20 pixels
GRID_WIDTH = Window.width / GRID_SIZE
GRID_HEIGHT = Window.height / GRID_SIZE
CENTER_X = Window.width / 2
CENTER_Y = Window.height / 2
MIN_INFLUENCE = 20

t = 0
c = 0

jaja = Default2.new(2, 0,10, Point.new(CENTER_X,CENTER_Y))



spaceship = AcceleratingSpaceship.new(0.15, 20, 0, 0.03, Point.new(CENTER_X, CENTER_Y - 20))
@bullets = []
@polygons = []
@polygons.push jaja
update do
  t = (t + 1) % Window::fps_cap
  c -= 1
  on :key_held do |event|
    if ['left', 'a', 'A'].include? event.key
      @rotation = 'left'
    elsif ['right', 'd', 'D'].include? event.key
      @rotation = 'right'
    elsif ['w', 'W', 'up'].include? event.key
      @thrust = true
    elsif event.key == 'space' && c <= 0
      @bullets.push spaceship.fire
      c = Window::fps_cap / 4
    end
    if event.key == 'q' or event.key == 'Q' # quitting game
      exit
    end
  end
  on :key_up do |event|
    if ['left', 'a', 'A', 'right', 'd', 'D'].include? event.key
      @rotation = 0
    elsif ['up', 'w', 'W'].include? event.key
      @thrust = false
    end
  end

  clear
  spaceship.move
  @bullets.each { |b| b.move }
  if @rotation == 'left'
    spaceship.rotate_by(Math::PI / 36)
  elsif @rotation == 'right'
    spaceship.rotate_by(-Math::PI / 36)
  end
  if @thrust
    spaceship.thrust
  end
  @polygons.each do |p|
    if @bullets.reduce(false) do |accum, b|
      if p.hit_by?(b)
        @bullets.delete b
        true
      else
        accum
      end
    end
      new = p.break(0.5, Math::PI / 4)
      @polygons.push new unless new.influence < MIN_INFLUENCE
      @polygons.delete p if p.influence < MIN_INFLUENCE
    end
  end
  @bullets.each do |b|
    b.move
    b.draw
  end
  @polygons.each do |p|
    p.move
    p.move_by(-Window.width, 0) if p.points[0].x_pos > Window.width
    p.move_by(Window.width, 0) if p.points[0].x_pos < 0
    p.move_by(0, -Window.height) if p.points[0].y_pos > Window.height
    p.move_by(0, Window.height) if p.points[0].y_pos < 0
    p.rotate_by(Math::PI / 36)
    Circle.new(x: 90, y: 90, radius: 10, color: 'red') if p.touches?(spaceship)
    p.draw
  end
  spaceship.draw
  # PointsLine.new(spaceship.points[0], Point.new(spaceship.points[0].x_pos + 5 * spaceship.velocity * Math.cos(spaceship.angle), spaceship.points[0].y_pos + 5 * spaceship.velocity * Math.sin(spaceship.angle))).draw

end

show
