require 'set'
require 'forwardable'
require_relative 'map'
require_relative 'tile'

q1 = Gandhi::Quad.new(Map::Point.new(0, 0), Map::Point.new(10, 10))
q2 = Gandhi::QuadTree.new q1, 1
puts q2.find(q1)

q3 = Gandhi::Quad.new(Map::Point.new(0, 0), Map::Point.new(1, 1))
q2.insert(q3)
puts q2.find(q3)

q4 = Gandhi::Quad.new(Map::Point.new(9, 9), Map::Point.new(10, 10))
q2.insert(q4)
puts q2.find(q4)
