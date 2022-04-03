require 'set'
require 'forwardable'
require_relative 'map'
require_relative 'tile'

quad1 = Gandhi::QuadShape.new(Gandhi::Point.new(0, 0), Gandhi::Point.new(10, 10)) 
tile1 = Gandhi::Tile.new quad1
tree = Gandhi::QuadTree.new quad1, 2
tree.insert tile1
quad2 = Gandhi::QuadShape.new(Gandhi::Point.new(2.5, 2.5), Gandhi::Point.new(7.5, 7.5)) 
puts tree.shapes quad2
