require 'set'
require_relative 'map'
require_relative 'tile'

#quad1 = Gandhi::QuadShape.new(Gandhi::Point.new(1, 2), Gandhi::Point.new(2, 4))
#quad2 = Gandhi::QuadShape.new(Gandhi::Point.new(0, 0), Gandhi::Point.new(3, 3))
#puts quad1.intersection quad2
#puts quad2.intersection quad1

quad1 = Gandhi::QuadShape.new(Gandhi::Point.new(0, 0), Gandhi::Point.new(10, 10)) 
tile1 = Gandhi::Tile.new quad1
tree = Gandhi::QuadTree.new quad1, 2
tree.insert tile1
quad2 = Gandhi::QuadShape.new(Gandhi::Point.new(3, 3), Gandhi::Point.new(7, 7)) 
puts tree.shapes quad2
