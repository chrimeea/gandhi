module Gandhi
  class PointTest < Test::Unit::TestCase
    def test_initialize
      p = Point.new(1, 2)
      assert_equal(p.x, 1)
      assert_equal(p.y, 2)
    end
    
    def test_eql
      assert(Point.new(7, 4).eql? Point.new(7.0, 4.0))
      assert_false(Point.new(1, 2).eql? Point.new(1, 3))
    end
    
    def test_translate
      assert(Point.new(9, 6).eql? Point.new(3, 5).translate(6, 1))
    end

    def test_hash
      assert_equal(Point.new(3, 6).hash, Point.new(3, 6).hash)
      assert_not_equal(Point.new(3, 6).hash, Point.new(6, 3).hash)
    end
  end

  class ShapeTest < Test::Unit::TestCase
    def test_eql
      assert(Shape.new([Point.new(7, 4), Point.new(8, 9)]).eql? Shape.new([Point.new(7, 4), Point.new(8, 9)]))
      assert_false(Shape.new([Point.new(7, 4), Point.new(8, 9)]).eql? Shape.new([Point.new(8, 9), Point.new(7, 4)]))
    end

    def test_hash
      assert_equal(Shape.new([Point.new(7, 4), Point.new(8, 9)]).hash, Shape.new([Point.new(7, 4), Point.new(8, 9)]).hash)
      assert_not_equal(Shape.new([Point.new(7, 4), Point.new(8, 9)]).hash, Shape.new([Point.new(8, 9), Point.new(7, 4)]).hash)
    end
  end

  class QuadShapeTest < Test::Unit::TestCase
    def test_initialize
      top_left = Point.new(1, 1)
      bottom_right = Point.new(2, 2)
      q = QuadShape.new(top_left, bottom_right)
      assert_equal(q.top_left, top_left)
      assert_equal(q.bottom_right, bottom_right)
    end
    
    def test_center
      assert(QuadShape.new(Point.new(1, 1), Point.new(2, 4)).center.eql? Point.new(1.5, 2.5))
    end

    def test_width
      assert_equal(QuadShape.new(Point.new(1, 1), Point.new(3, 4)).width, 2)
    end

    def test_height
      assert_equal(QuadShape.new(Point.new(1, 1), Point.new(3, 4)).height, 3)
    end

    def test_leftY?
      assert_true(QuadShape.new(Point.new(1, 1), Point.new(3, 4)).leftY? 4)
      assert_true(QuadShape.new(Point.new(1, 1), Point.new(3, 4)).leftY? 3)
      assert_false(QuadShape.new(Point.new(1, 1), Point.new(3, 4)).leftY? 2)
      assert_false(QuadShape.new(Point.new(1, 1), Point.new(3, 4)).leftY?(-1))
    end

    def test_aboveX?
      assert_true(QuadShape.new(Point.new(1, 1), Point.new(3, 4)).aboveX?(4))
      assert_true(QuadShape.new(Point.new(1, 1), Point.new(3, 4)).aboveX? 5)
      assert_false(QuadShape.new(Point.new(1, 1), Point.new(3, 4)).aboveX? 2)
      assert_false(QuadShape.new(Point.new(1, 1), Point.new(3, 4)).aboveX? 3)
    end

    def test_intersectsY?
      assert_true(QuadShape.new(Point.new(1, 1), Point.new(3, 4)).intersectsY? 2.5)
      assert_false(QuadShape.new(Point.new(1, 1), Point.new(3, 4)).intersectsY? 0)
      assert_false(QuadShape.new(Point.new(1, 1), Point.new(3, 4)).intersectsY? 1)
      assert_false(QuadShape.new(Point.new(1, 1), Point.new(3, 4)).intersectsY? 3)
      assert_false(QuadShape.new(Point.new(1, 1), Point.new(3, 4)).intersectsY? 4)
    end

    def test_intersectsX?
      assert_true(QuadShape.new(Point.new(1, 1), Point.new(3, 4)).intersectsX? 3)
      assert_false(QuadShape.new(Point.new(1, 1), Point.new(3, 4)).intersectsX? 0)
      assert_false(QuadShape.new(Point.new(1, 1), Point.new(3, 4)).intersectsX? 1)
      assert_false(QuadShape.new(Point.new(1, 1), Point.new(3, 4)).intersectsX? 4)
      assert_false(QuadShape.new(Point.new(1, 1), Point.new(3, 4)).intersectsX? 5)
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
      assert(QuadTextureMapping.new.eql? QuadShape.new(Point.new(0, 0), Point.new(1, 1)))
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
end
