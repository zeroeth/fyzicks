require 'rubygems'
require 'bundler/setup'
require 'chingu'
require 'chipmunk'


module Chingu
  module Traits
    module Awesome
      def setup_trait options
        super
        self.x = rand $window.width
        self.y = rand $window.height
        self.velocity_y = -(rand(20)+1)
      end


      def update_trait
        super
        if self.y < 0
          self.y = $window.height
        end
      end
    end
  end
end



class Numeric
  def radians_to_vec2
    CP::Vec2.new(Math::cos(self), Math::sin(self))
  end


  def self.set_steps(value)
    @@substeps = value
  end

  def sd
    self/@@substeps
  end
end



class TileManager
  attr_accessor :tiles

  def random_tile
    self.tiles ||= load_tiles
    self.tiles.sample
  end


  def initialize(options = {})
    size = options[:sprite_size]
    @@tiles ||= {}
    @@tiles[options[:file]] ||= Gosu::Image.load_tiles($window, Gosu::Image[options[:file]], size, size, true)
    self.tiles = @@tiles[options[:file]]
  end
end



class TechShip < Chingu::GameObject
  attr_accessor :shape, :body

  def setup
    super
    self.image = TileManager.new(file: 'tech_ships.png', sprite_size: 28).random_tile

    mass, radius, offset = (rand*1000.0), (28/2), CP::Vec2.new(0.0, 0.0)
    moment = CP.moment_for_circle(mass, 0, radius, offset)

    self.body  = CP::Body.new(mass, moment)
    self.shape = CP::Shape::Circle.new(body, radius, offset)
    self.shape.object = self
    self.shape.collision_type = :ship
    self.shape.e = 0.0
    self.shape.u = 0.8

    # fling ship in one direction, spinning
    self.body.p = CP::Vec2.new(rand * $window.width, rand * $window.height)
    self.body.a = rand * Math::PI * 2
    self.body.v =  self.shape.body.a.radians_to_vec2 * (rand * 200.0)
    self.body.w = 10.0.sd

    # fling ship spinning slowly, with thrust being applied
    # TODO

    parent.add_to_space self
  end


  def update
    super

    self.angle = body.a.radians_to_gosu
    self.x = body.p.x
    self.y = body.p.y
  end
end

class RedSquare < Chingu::GameObject
  attr_accessor :shape
  def setup
    super
    self.image = "redsquare.png"
  end

  def update
    super

    self.angle = parent.floor_body.a.radians_to_gosu
    self.x     = parent.floor_body.p.x
    self.y     = parent.floor_body.p.y
  end
end

class Dot < Chingu::GameObject
  def setup
    super
    self.image = "whitecircle.png"
  end
end


class Game < Chingu::Window
  attr_accessor :space, :substeps, :floor_body, :floor_shape

  def setup
    super
    self.input = { esc: :exit }
    self.space = CP::Space.new
    self.substeps = Numeric.set_steps 30
    self.space.damping = 0.8
    self.space.gravity = (Math::PI/2.0).radians_to_vec2 * 100

=begin
    self.space.add_collision_func(:ship, :floor) do |ship_shape, floor_shape|
      game_objects.each do |obj|
        if obj.shape == ship_shape
          obj.image = "whitecircle.png"
          space.remove_body obj.body
          space.remove_shape obj.shape
        end
      end
    end
=end

    add_floor
    RedSquare.create
    100.times{ TechShip.create }
  end


  def update
    super

    self.substeps.times do
      self.space.step((1.0/60.0).sd)
    end
  end


  def add_to_space game_object
    self.space.add_body  game_object.body
    self.space.add_shape game_object.shape
  end

  def add_floor
    self.floor_body = CP::Body.new CP::INFINITY, CP::INFINITY
    floor_body.p = CP::Vec2.new($window.width/2, $window.height/2)
    floor_body.a = 0

    self.floor_shape = CP::Shape::Circle.new(floor_body, 100, CP::Vec2.new(0,0))
    self.floor_shape.collision_type = :ship
    self.floor_shape.u = 1
    self.floor_shape.e = 1

    self.space.add_body floor_body
    self.space.add_shape floor_shape
  end
end

Game.new.show
