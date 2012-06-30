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

    mass, moment = 10.0, 150.0
    self.body = CP::Body.new(mass, moment)

    radius, offset = (28/2), CP::Vec2.new(0.0, 0.0)
    self.shape = CP::Shape::Circle.new(body, radius, offset)

    self.shape.body.p = CP::Vec2.new(rand * $window.width, rand * $window.height)
    self.shape.body.a = rand * Math::PI * 2
    self.shape.body.v =  self.shape.body.a.radians_to_vec2 * (rand * 200.0)
    # apply torque is the one that needs scaling..

    parent.add_to_space self
  end


  def update
    super

    self.angle = @shape.body.a.radians_to_gosu
    self.x = @shape.body.p.x
    self.y = @shape.body.p.y
  end
end



class Game < Chingu::Window
  attr_accessor :space, :substeps

  def setup
    super
    self.input = { esc: :exit }
    self.space = CP::Space.new
    self.substeps = Numeric.set_steps 6
    self.space.damping = 0.8

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
end

Game.new.show
