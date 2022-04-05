require 'test/unit'
require 'set'
require_relative 'map'
require_relative 'tile'

class PointTest < Test::Unit::TestCase
  def test_initialize
    p = Gandhi::Point.new(1, 2)
    assert_equal(p.x, 1)
    assert_equal(p.y, 2)
  end
  
  def test_eql
    assert(Gandhi::Point.new(7, 4).eql? Gandhi::Point.new(7.0, 4.0))
    assert_false(Gandhi::Point.new(1, 2).eql? Gandhi::Point.new(1, 3))
  end

  def test_translate
    assert(Gandhi::Point.new(9, 6).eql? Gandhi::Point.new(3, 5).translate(6, 1))
  end

  def test_hash
    assert_equal(Gandhi::Point.new(3, 6).hash, Gandhi::Point.new(3, 6).hash)
    assert_not_equal(Gandhi::Point.new(3, 6).hash, Gandhi::Point.new(6, 3).hash)
  end
end

class ShapeTest < Test::Unit::TestCase
  def test_eql
    assert(Gandhi::Shape.new([Gandhi::Point.new(7, 4), Gandhi::Point.new(8, 9)]).eql? Gandhi::Shape.new([Gandhi::Point.new(7, 4), Gandhi::Point.new(8, 9)]))
    assert_false(Gandhi::Shape.new([Gandhi::Point.new(7, 4), Gandhi::Point.new(8, 9)]).eql? Gandhi::Shape.new([Gandhi::Point.new(8, 9), Gandhi::Point.new(7, 4)]))
  end

  def test_hash
    assert_equal(Gandhi::Shape.new([Gandhi::Point.new(7, 4), Gandhi::Point.new(8, 9)]).hash, Gandhi::Shape.new([Gandhi::Point.new(7, 4), Gandhi::Point.new(8, 9)]).hash)
    assert_not_equal(Gandhi::Shape.new([Gandhi::Point.new(7, 4), Gandhi::Point.new(8, 9)]).hash, Gandhi::Shape.new([Gandhi::Point.new(8, 9), Gandhi::Point.new(7, 4)]).hash)
  end
end

class QuadShapeTest < Test::Unit::TestCase
  def test_initialize
    top_left = Gandhi::Point.new(1, 1)
    bottom_right = Gandhi::Point.new(2, 2)
    q = Gandhi::QuadShape.new(top_left, bottom_right)
    assert_equal(q.top_left, top_left)
    assert_equal(q.bottom_right, bottom_right)
  end
  
  def test_center
    assert(Gandhi::QuadShape.new(Gandhi::Point.new(1, 1), Gandhi::Point.new(2, 4)).center.eql? Gandhi::Point.new(1.5, 2.5))
  end

  def test_width
    assert_equal(Gandhi::QuadShape.new(Gandhi::Point.new(1, 1), Gandhi::Point.new(3, 4)).width, 2)
  end

  def test_height
    assert_equal(Gandhi::QuadShape.new(Gandhi::Point.new(1, 1), Gandhi::Point.new(3, 4)).height, 3)
  end

  def test_leftY?
    assert_true(Gandhi::QuadShape.new(Gandhi::Point.new(1, 1), Gandhi::Point.new(3, 4)).leftY? 4)
    assert_true(Gandhi::QuadShape.new(Gandhi::Point.new(1, 1), Gandhi::Point.new(3, 4)).leftY? 3)
    assert_false(Gandhi::QuadShape.new(Gandhi::Point.new(1, 1), Gandhi::Point.new(3, 4)).leftY? 2)
    assert_false(Gandhi::QuadShape.new(Gandhi::Point.new(1, 1), Gandhi::Point.new(3, 4)).leftY?(-1))
  end

  def test_aboveX?
    assert_true(Gandhi::QuadShape.new(Gandhi::Point.new(1, 1), Gandhi::Point.new(3, 4)).aboveX?(4))
    assert_true(Gandhi::QuadShape.new(Gandhi::Point.new(1, 1), Gandhi::Point.new(3, 4)).aboveX? 5)
    assert_false(Gandhi::QuadShape.new(Gandhi::Point.new(1, 1), Gandhi::Point.new(3, 4)).aboveX? 2)
    assert_false(Gandhi::QuadShape.new(Gandhi::Point.new(1, 1), Gandhi::Point.new(3, 4)).aboveX? 3)
  end

  def test_intersectsY?
    assert_true(Gandhi::QuadShape.new(Gandhi::Point.new(1, 1), Gandhi::Point.new(3, 4)).intersectsY? 2.5)
    assert_false(Gandhi::QuadShape.new(Gandhi::Point.new(1, 1), Gandhi::Point.new(3, 4)).intersectsY? 0)
    assert_false(Gandhi::QuadShape.new(Gandhi::Point.new(1, 1), Gandhi::Point.new(3, 4)).intersectsY? 1)
    assert_false(Gandhi::QuadShape.new(Gandhi::Point.new(1, 1), Gandhi::Point.new(3, 4)).intersectsY? 3)
    assert_false(Gandhi::QuadShape.new(Gandhi::Point.new(1, 1), Gandhi::Point.new(3, 4)).intersectsY? 4)
  end

  def test_intersectsX?
    assert_true(Gandhi::QuadShape.new(Gandhi::Point.new(1, 1), Gandhi::Point.new(3, 4)).intersectsX? 3)
    assert_false(Gandhi::QuadShape.new(Gandhi::Point.new(1, 1), Gandhi::Point.new(3, 4)).intersectsX? 0)
    assert_false(Gandhi::QuadShape.new(Gandhi::Point.new(1, 1), Gandhi::Point.new(3, 4)).intersectsX? 1)
    assert_false(Gandhi::QuadShape.new(Gandhi::Point.new(1, 1), Gandhi::Point.new(3, 4)).intersectsX? 4)
    assert_false(Gandhi::QuadShape.new(Gandhi::Point.new(1, 1), Gandhi::Point.new(3, 4)).intersectsX? 5)
  end

  def test_splitY
  end

  def test_splitX
  end

  def test_splitXY
  end

  def test_convertX
  end

  def test_convertY
  end

  def test_splitQuad
  end

  def test_intersection
  end
end

class QuadTextureMappingTest < Test::Unit::TestCase
  def test_initialize
    assert(Gandhi::QuadTextureMapping.new.eql? Gandhi::QuadShape.new(Gandhi::Point.new(0, 0), Gandhi::Point.new(1, 1)))
  end
end

class QuadTileTest < Test::Unit::TestCase
  def test_initialize
  end

  def test_splitY
  end

  def test_splitX
  end

  def test_splitXY
  end

  def test_splitQuad
  end
end
