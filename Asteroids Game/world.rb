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
require_relative 'AsteroidTypes/default2'
require 'ruby2d'

class World

  ASTEROID_SPEED = 2
  ASTEROID_SIZE = 0.6
  # Influence is a rough estimate of an asteroid's size. Min influence is intended to limit the minimum size of asteroids
  MIN_INFLUENCE = 40
  # Asteroid interval sets the time between asteroid spawns
  ASTEROID_INTERVAL = 1600
  # Asteroids will not spawn when max asteroids is exceeded. If exceeded by far, shooting an asteroid will not create new ones, only shrink them
  MAX_ASTEROIDS = 20

  # For spaceship controls. Make these values negative for an interesting experience. Fighters also use these values, though modified to make them clumsier
  SPACESHIP_THRUST = 8.0
  SPACESHIP_DRAG = 0.05
  SPACESHIP_SIZE = 20
  SPACESHIP_ROTATION = Math::PI
  FIRE_INTERVAL = 120

  # If you turn on bullet hell, either reduce fire interval or turn off friendly fire
  # Bullet hell makes bullets wrap around the screen just as asteroids and spaceships do. When off, bullets that leave the screen are deleted
  # Fighters are harmless when friendly fire is off. This can easily be changed by using a separate array for fighter bullets.
  INVINSIBLE = false
  FRIENDLY_FIRE = true
  BULLET_HELL = false

  # For cool spaceships. Feel free to add your own colors to this array.
  COLORS = ['green', 'purple', 'teal', 'fuchsia', 'aqua', 'lime', 'yellow', 'olive', 'orange']


  # I suggest increasing stupidity if you turn on good aim. The good aim constant is intended to, when false, make a player feel like they are dodging bullets, when in reality fighters are simply aiming at their backs instead of their fronts
  # Fighter stupidity just makes fighters worse at following the player as the constant increases
  # Fighters frequently run into asteroids: Making them invinsible to asteroids feels wrong/unfair, making them dodge asteroids would be very complex by comparison to their current intelligence (They just move towards a live player and shoot sometimes)
  SPAWN_FIGHTERS = true
  FIGHTERS_THRESHOLD = 0
  MAX_FIGHTERS = 3
  FIGHTER_FIRE_CHANCE = 120
  FIGHTER_SPAWN_RARITY = 300
  FIGHTER_STUPIDITY = 0
  GOOD_AIM = false

  SEED = Random.new


  def initialize(fps_cap, window_width, window_height)
    @fps_cap = fps_cap
    @width = window_width
    @height = window_height
    @a_interval = ASTEROID_INTERVAL / @fps_cap

    @bullets = []
    @spaceships = []
    @s_intervals = []
    @asteroids = []
    @fighters = []
    @all = [@bullets, @spaceships, @fighters, @asteroids]
    @score = 0
    add_spaceship
  end

  # movements is an array of [fire(true/false), thrust(true/false), rotation(1/0/-1)]
  def update(*movements)
    add_asteroids
    add_fighters
    spaceship_actions(movements)
    fighter_actions
    run_collisions
    move_all
    draw_all
  end

  def add_spaceship
    color = COLORS[SEED.rand(COLORS.size)]
    COLORS.delete color
    @spaceships.push AcceleratingSpaceship.new(SPACESHIP_THRUST / @fps_cap, SPACESHIP_SIZE, 0, SPACESHIP_DRAG, spaceship_spawn, color)
    @s_intervals.push FIRE_INTERVAL / @fps_cap
  end

  def add_fighters
    if @score >= FIGHTERS_THRESHOLD && @fighters.size < MAX_FIGHTERS && SPAWN_FIGHTERS && SEED.rand(FIGHTER_SPAWN_RARITY + 1).zero?
      site = SEED.rand(spawns.size)
      @fighters.push AcceleratingSpaceship.new(SPACESHIP_THRUST / @fps_cap / 1.5, SPACESHIP_SIZE * 1.5, 0, SPACESHIP_DRAG, Point.new(spawns[site][0], spawns[site][1]), 'silver')
    end
  end

  def game_over?
    spaceship_count.zero?
  end

  def spaceship_count
    @spaceships.size
  end

  def restart
    @score = 0
    @spaceships.each do |s|
      s.live = true
      dx = @width / 2 - s.points[0].x_pos
      dy = @height / 2 - s.points[0].y_pos
      s.move_by(dx, dy)
    end
    @asteroids = []
    @bullets = []
    @fighters = []
    @all = [@bullets, @spaceships, @fighters, @asteroids]
    @a_interval = ASTEROID_INTERVAL / @fps_cap
  end

  protected

  def run_collisions
    @asteroids.each do |a|
      a.move_by(-@width, 0) if a.points[0].x_pos > @width
      a.move_by(@width, 0) if a.points[0].x_pos < 0
      a.move_by(0, -@height) if a.points[0].y_pos > @height
      a.move_by(0, @height) if a.points[0].y_pos < 0
      @bullets.each do |b|
        if a.hit_by?(b)
          new = a.break(0.25 + SEED.rand(11) / 20.0, Math::PI * (1 / 8.0 + SEED.rand(11) * 3 / 80.0))
          @asteroids.push new unless a.influence < MIN_INFLUENCE || @asteroids.size > MAX_ASTEROIDS * 1.2
          @asteroids.delete a if a.influence < MIN_INFLUENCE
          @bullets.delete b
          @score += 1
          break
        end
      end
      @spaceships.each do |s|
        if (s.live?) && (a.weak_nearby? s.points[0]) && (a.touches? s)
          Circle.new(x: s.points[0].x_pos, y: s.points[0].y_pos, radius: 5, color: 'red')
          s.live = false unless INVINSIBLE
          @asteroids.delete a
          break
        end
      end
      @fighters.each do |f|
        if (f.live?) && (a.weak_nearby? f.points[0]) && (a.touches? f)
          Circle.new(x: f.points[0].x_pos, y: f.points[0].y_pos, radius: 5, color: 'red')
          @fighters.delete f
          @asteroids.delete a
          break
        end
      end
    end

    @spaceships.each do |s|
      if s.live?
        s.move_by(-@width, 0) if s.points[0].x_pos > @width
        s.move_by(@width, 0) if s.points[0].x_pos < 0
        s.move_by(0, -@height) if s.points[0].y_pos > @height
        s.move_by(0, @height) if s.points[0].y_pos < 0
        if FRIENDLY_FIRE
          @bullets.each do |b|
            if b.cooldown.zero? && s.hit_by?(b)
              Circle.new(x: s.points[0].x_pos, y: s.points[0].y_pos, radius: 5, color: 'red')
              s.live = false unless INVINSIBLE
              @bullets.delete b
              break
            end
          end
        end
      end
    end
    @fighters.each do |f|
      f.move_by(-@width, 0) if f.points[0].x_pos > @width
      f.move_by(@width, 0) if f.points[0].x_pos < 0
      f.move_by(0, -@height) if f.points[0].y_pos > @height
      f.move_by(0, @height) if f.points[0].y_pos < 0
      @bullets.each do |b|
        if b.cooldown.zero? && f.hit_by?(b)
          Circle.new(x: f.points[0].x_pos, y: f.points[0].y_pos, radius: 5, color: 'red')
          @score += 10
          @fighters.delete f
          @bullets.delete b
          break
        end
      end
    end

    @bullets.each do |b|
      if BULLET_HELL
        b.location.x_pos -= @width if b.location.x_pos > @width
        b.location.x_pos += @width if b.location.x_pos < 0
        b.location.y_pos -= @height if b.location.y_pos > @height
        b.location.y_pos += @height if b.location.y_pos < 0
      else
        @bullets.delete b unless b.location.x_pos.between?(0, @width) && b.location.y_pos.between?(0, @height)
      end
    end

  end

  def add_asteroids
    @a_interval -= 1
    if @a_interval <= 0 && @asteroids.size <= MAX_ASTEROIDS
      @a_interval = ASTEROID_INTERVAL / @fps_cap
      site = SEED.rand(spawns.size)
      size = ASTEROID_SIZE * (SEED.rand(14) / 10.0 + 0.5)
      @asteroids.push Default2.new(ASTEROID_SPEED, Math::PI / (SEED.rand(10) + 1), size, Point.new(spawns[site][0], spawns[site][1]))
      @asteroids[-1].rotate_by(SEED.rand(11) / 5.0 * Math::PI)
    end
  end

  def spaceship_actions(movements)
    s = 0
    @spaceships.each do |spaceship|
      break if movements[s].nil?
      @s_intervals[s] -= 1
      if movements[s][0] && @s_intervals[s] <= 0
        @bullets.push spaceship.fire if spaceship.live?
        @s_intervals[s] = FIRE_INTERVAL / @fps_cap
      end

      spaceship.thrust if movements[s][1]
      raise ArgumentError, 'Rotation is -1/0/1' unless [-1, 0, 1].include? movements[s][2]
      spaceship.rotate_by movements[s][2] * SPACESHIP_ROTATION / @fps_cap

      s += 1
    end
  end

  def fighter_actions
    victim = @spaceships.reduce { |accum, s| accum.live? ? accum : s }
    @fighters.each do |f|
      if SEED.rand(FIGHTER_STUPIDITY + 1).zero?
        if GOOD_AIM
          f.auto_turn(victim.points[0], SPACESHIP_ROTATION / @fps_cap)
        else
          f.auto_turn(victim.center_point, SPACESHIP_ROTATION / @fps_cap)
        end
      end
      f.thrust
      @bullets.push f.fire if SEED.rand(FIGHTER_FIRE_CHANCE + 1).zero?
    end
  end

  def move_all
    @all.each { |e| e.each { |f| f.move } }
  end

  def draw_all
    @all.each { |e| e.each { |f| f.draw } }
    @score_text = Text.new(@score.to_s)
  end

  def spaceship_spawn
    Point.new(@width / 2, @height / 2 - 20)
  end

  def height
    @height
  end

  def width
    @width
  end

  def spawns
    [[0, @height / 3], [@width / 4, @height], [@width / 4, 0], [@width / 2, 0], [0, 2 * @height / 3], [@width / 2, @height], [3 * @width / 4, @height], [3 * @width / 4, 0], [@width, @height / 3], [@width, 2 * @height / 3]]
  end

end
