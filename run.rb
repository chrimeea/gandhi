require 'set'
require 'forwardable'
require_relative 'map'
require_relative 'tile'

q1 = Gandhi::QuadShape.new(Gandhi::Point.new(0, 0), Gandhi::Point.new(10, 10))
q2 = Gandhi::QuadTree.new q1, 1
puts q2.shapes(q1)

q3 = Gandhi::QuadShape.new(Gandhi::Point.new(0, 0), Gandhi::Point.new(1, 1))
q2.insert(q3)
puts q2.shapes(q1)

q4 = Gandhi::QuadShape.new(Gandhi::Point.new(9, 9), Gandhi::Point.new(10, 10))
q2.insert(q4)
puts q2.shapes(q1)
