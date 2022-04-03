require 'set'
require 'forwardable'
require_relative 'map'
require_relative 'tile'

q1_quad = Gandhi::QuadShape.new(Gandhi::Point.new(0, 0), Gandhi::Point.new(10, 10)) 
q1_tile = Gandhi::Tile.new q1_quad
q2 = Gandhi::QuadTree.new q1_quad, 2
q2.insert(q1_tile)
puts q2.shapes

# q3 = Gandhi::QuadShape.new(Gandhi::Point.new(0, 0), Gandhi::Point.new(1, 1))
# q2.insert(q3)
# puts q2.shapes(q1)

# q4 = Gandhi::QuadShape.new(Gandhi::Point.new(9, 9), Gandhi::Point.new(10, 10))
# q2.insert(q4)
# puts q2.shapes(q1)
