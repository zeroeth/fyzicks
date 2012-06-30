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
  traits :velocity, :awesome

  def setup
    super
    self.image = TileManager.new(file: 'tech_ships.png', sprite_size: 28).random_tile
  end
end

class Game < Chingu::Window
  def setup
    super
    self.input = { esc: :exit }
    500.times{ TechShip.create }
  end
end

Game.new.show
