require 'rubygems'
require 'bundler/setup'
require 'chingu'

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
  trait :velocity

  def setup
    super
    self.image = TileManager.new(file: 'tech_ships.png', sprite_size: 28).random_tile
    self.x = rand($window.width)
    self.y = rand($window.height)
    self.velocity_y = -(rand(20)+1)
  end

  def update
    super

    if self.y < 0
      self.y = $window.height
    end
  end
end

class GlowShip < Chingu::GameObject
  def setup
    super
    self.image = TileManager.new(file: 'ships.png', sprite_size: 57).random_tile
    self.x = rand($window.width)
    self.y = rand($window.height)
  end
end


class GlowEnemy < Chingu::GameObject
  def setup
    super
    self.image = TileManager.new(file: 'enemies.png', sprite_size: 37).random_tile
    self.x = rand($window.width)
    self.y = rand($window.height)
  end
end

class Game < Chingu::Window

  def setup
    super
    self.input = { esc: :exit }
    500.times{ TechShip.create }
  end

  def draw
    super
  end
end

Game.new.show
