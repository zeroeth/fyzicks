require 'rubygems'
require 'bundler/setup'
require 'chingu'
require 'chipmunk'


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



class Array
  def to_vec2_list
    self.collect{|element| element.to_vec2 }
  end


  def to_vec2
    CP::Vec2.new self[0], self[1]
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



class PhysicalObject < Chingu::GameObject
  attr_accessor :shape, :body

  def update
    super

    self.angle = body.a.radians_to_gosu
    self.x = body.p.x
    self.y = body.p.y
  end


  def location=(values)
    body.p.x, body.p.y = values
  end


  def add_to_space
    parent.add_to_space self
  end
end



class TechShip < PhysicalObject
  def setup
    super
    self.image = TileManager.new(file: 'tech_ships.png', sprite_size: 28).random_tile

    mass, radius, offset = (rand*1000.0), (28/2), [0.0, 0.0].to_vec2
    moment = CP.moment_for_circle(mass, 0, radius, offset)

    self.body  = CP::Body.new(mass, moment)
    self.shape = CP::Shape::Circle.new(body, radius, offset)

    shape.object = self # access to chingu object from chipmunk collisions
    shape.e = 0.0 # elasticity
    shape.u = 0.8 # friction

    # fling ship in one direction, spinning
    body.p = [rand * $window.width, rand * $window.height].to_vec2
    body.a = rand * Math::PI * 2
    body.v = self.shape.body.a.radians_to_vec2 * (rand * 200.0)
    body.w = 0.0 # rotational velocity

    # fling ship spinning slowly, with thrust being applied (a slow arc)
    # TODO

    add_to_space
  end
end



class Block < PhysicalObject
  def setup
    super
    self.image = "metroid_block.png"

    shape_array = [[0.0, 0.0], [0.0, 32.0], [32.0, 32.0], [32.0, 0.0]].to_vec2_list

    mass = rand * 10000.0
    moment = CP.moment_for_poly mass, shape_array, [0.0, 0,0].to_vec2
    self.body = CP::Body.new mass, moment
    body.p = [$window.width/2, $window.height/2].to_vec2
    body.a = 0.0

    self.shape = CP::Shape::Poly.new(body, shape_array, [-16.0,-16.0].to_vec2)

    shape.e = 0.0
    shape.u = 1.0

    add_to_space
  end
end

class StaticWall < PhysicalObject
  def setup
    super
    self.image = "metroid_wall.png"

    self.body = CP::StaticBody.new
    body.p = [$window.width/2, $window.height/2].to_vec2
    body.a = 0.0

    shape_array = [[0.0, 0.0], [0.0, 320.0], [32.0, 320.0], [32.0, 0.0]].to_vec2_list
    self.shape = CP::Shape::Poly.new(body, shape_array, [-16.0,-160.0].to_vec2)

    shape.e = 0.0
    shape.u = 1.0

    add_to_space
  end


  def add_to_space
    parent.add_static self
  end
end


class PinnedWall < PhysicalObject
  attr_accessor :rotation_body, :pin_joint
  def setup
    super

    self.image = "metroid_wall.png"

    center_point = [$window.width/2, $window.height/2].to_vec2

    shape_array = [[0.0, 0.0], [0.0, 320.0], [32.0, 320.0], [32.0, 0.0]].to_vec2_list

    mass = 10000.0
    moment = CP.moment_for_poly mass, shape_array, [0.0, 0,0].to_vec2
    self.body = CP::Body.new mass, moment
    body.p = center_point
    body.a = 0.0

    self.shape = CP::Shape::Poly.new(body, shape_array, CP::Vec2.new(-16.0,-160.0))

    shape.e = 0.0
    shape.u = 1.0

    # giving this position doesnt work
    self.rotation_body = CP::StaticBody.new

    self.pin_joint = CP::Constraint::PinJoint.new body, rotation_body, [0,0].to_vec2, center_point

    add_to_space
  end


  def add_to_space
    parent.add_to_space self
    parent.add_constraint self.pin_joint
  end
end

class Dot < Chingu::GameObject
  def setup
    super
    self.image = "whitecircle.png"
  end
end



class Game < Chingu::Window
  attr_accessor :space, :substeps

  def setup
    super
    self.input = { esc: :exit, left_mouse_button: :spawn_ship }
    self.space = CP::Space.new
    self.substeps = Numeric.set_steps 10

    space.damping = 0.8
    space.gravity = (Math::PI/2.0).radians_to_vec2 * 100

    # try pinning next
    walls = 2.times.collect{ StaticWall.create }
    walls.each  do |w|
      w.location = [rand($window.height), rand($window.width)]
      w.body.a = (rand * Math::PI * 2)
    end

    PinnedWall.create

    blocks = 50.times.collect{ Block.create }
    blocks.each  do |w|
      w.location = [rand($window.height), rand($window.width)]
      w.body.a = (rand * Math::PI * 2)
    end

    50.times{ TechShip.create }
  end


  def update
    super

    self.substeps.times do
      self.space.step((1.0/60.0).sd)
    end

    self.space.rehash_static
  end


  def add_to_space game_object
    space.add_body  game_object.body
    space.add_shape game_object.shape
  end


  def add_static game_object
    space.add_static_shape game_object.shape
  end

  def add_constraint constraint
    space.add_constraint constraint
  end


  def add_constraint constraint
    space.add_constraint constraint
  end


  def spawn_ship
    ship = TechShip.create
    ship.location = mouse_x, mouse_y
  end
end

Game.new.show
