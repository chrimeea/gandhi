# frozen_string_literal: true

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
      left, right = QuadShape.new(Point.new(1, 1), Point.new(3, 4)).splitY 2
      assert_true(left.eql? QuadShape.new(Point.new(1, 1), Point.new(2, 4)))
      assert_true(right.eql? QuadShape.new(Point.new(2, 1), Point.new(3, 4)))
      left, right = QuadShape.new(Point.new(1, 1), Point.new(3, 4)).splitY 0
      assert_nil(left)
      assert_true(right.eql? QuadShape.new(Point.new(1, 1), Point.new(3, 4)))
      left, right = QuadShape.new(Point.new(1, 1), Point.new(3, 4)).splitY 4
      assert_true(left.eql? QuadShape.new(Point.new(1, 1), Point.new(3, 4)))
      assert_nil(right)
    end

    def test_splitX
      up, down = QuadShape.new(Point.new(1, 1), Point.new(3, 4)).splitX 2
      assert_true(up.eql? QuadShape.new(Point.new(1, 1), Point.new(3, 2)))
      assert_true(down.eql? QuadShape.new(Point.new(1, 2), Point.new(3, 4)))
      up, down = QuadShape.new(Point.new(1, 1), Point.new(3, 4)).splitX 0
      assert_nil(up)
      assert_true(down.eql? QuadShape.new(Point.new(1, 1), Point.new(3, 4)))
      up, down = QuadShape.new(Point.new(1, 1), Point.new(3, 4)).splitX 4
      assert_true(up.eql? QuadShape.new(Point.new(1, 1), Point.new(3, 4)))
      assert_nil(down)
    end

    def test_splitXY
      top_right, top_left, bottom_left, bottom_right = QuadShape.new(Point.new(1, 1), Point.new(3, 4)).splitXY Point.new(2, 2)
      assert_true(top_right.eql? QuadShape.new(Point.new(2, 1), Point.new(3, 2)))
      assert_true(top_left.eql? QuadShape.new(Point.new(1, 1), Point.new(2, 2)))
      assert_true(bottom_left.eql? QuadShape.new(Point.new(1, 2), Point.new(2, 4)))
      assert_true(bottom_right.eql? QuadShape.new(Point.new(2, 2), Point.new(3, 4)))
      top_right, top_left, bottom_left, bottom_right = QuadShape.new(Point.new(1, 1), Point.new(3, 4)).splitXY Point.new(5, 4)
      #todo: add all cases
    end

    def test_convertX
      q1 = QuadShape.new(Point.new(1, 1), Point.new(3, 4))
      q2 = QuadShape.new(Point.new(0.2, 0.2), Point.new(1.2, 1.2))
      assert_true(q1.convertX(q2, 2).eql? 0.7)
    end

    def test_convertY
      q1 = QuadShape.new(Point.new(1, 1), Point.new(3, 5))
      q2 = QuadShape.new(Point.new(0.2, 0.2), Point.new(1.2, 1.2))
      assert_true(q1.convertY(q2, 2).eql? 0.45)
    end

    def test_split_quad
      q1 = QuadShape.new(Point.new(1, 1), Point.new(3, 5))
      q2 = QuadShape.new(Point.new(2, 3), Point.new(3, 4))
      assert_true(q1.split_quad(q2).eql? q2)
    end

    def test_intersection
      q1 = QuadShape.new(Point.new(1, 1), Point.new(3, 5))
      assert_true(q1.intersection(q1).eql? q1)
      q1 = QuadShape.new(Point.new(1, 1), Point.new(4, 5))
      q2 = QuadShape.new(Point.new(1, 1), Point.new(5, 6))
      assert_true(q1.intersection(q2).eql? q1)
      assert_true(q2.intersection(q1).eql? q1)
      q1 = QuadShape.new(Point.new(1, 1), Point.new(3, 5))
      q2 = QuadShape.new(Point.new(1, 5), Point.new(4, 6))
      assert_nil(q1.intersection(q2))
      assert_nil(q2.intersection(q1))
      q1 = QuadShape.new(Point.new(1, 1), Point.new(4, 5))
      q2 = QuadShape.new(Point.new(2, 3), Point.new(3, 4))
      assert_true(q1.intersection(q2).eql? q2)
      assert_true(q2.intersection(q1).eql? q2)
      q1 = QuadShape.new(Point.new(1, 1), Point.new(3, 5))
      q2 = QuadShape.new(Point.new(2, 3), Point.new(4, 6))
      assert_true(q1.intersection(q2).eql? QuadShape.new(Point.new(2, 3), Point.new(3, 5)))
      assert_true(q2.intersection(q1).eql? QuadShape.new(Point.new(2, 3), Point.new(3, 5)))
      q1 = QuadShape.new(Point.new(5, 2), Point.new(7, 8))
      q2 = QuadShape.new(Point.new(2, 6), Point.new(6, 9))
      assert_true(q1.intersection(q2).eql? QuadShape.new(Point.new(5, 6), Point.new(6, 8)))
      assert_true(q2.intersection(q1).eql? QuadShape.new(Point.new(5, 6), Point.new(6, 8)))
      q1 = QuadShape.new(Point.new(1, 1), Point.new(5, 5))
      q2 = QuadShape.new(Point.new(2, 2), Point.new(4, 6))      
      assert_true(q1.intersection(q2).eql? QuadShape.new(Point.new(2, 2), Point.new(4, 5)))
      assert_true(q2.intersection(q1).eql? QuadShape.new(Point.new(2, 2), Point.new(4, 5)))
      q1 = QuadShape.new(Point.new(1, 1), Point.new(5, 5))
      q2 = QuadShape.new(Point.new(2, 2), Point.new(6, 4))      
      assert_true(q1.intersection(q2).eql? QuadShape.new(Point.new(2, 2), Point.new(5, 4)))
      assert_true(q2.intersection(q1).eql? QuadShape.new(Point.new(2, 2), Point.new(5, 4)))
    end
  end

  class QuadTextureMappingTest < Test::Unit::TestCase
    def test_initialize
      assert(QuadTextureMapping.new.eql? QuadShape.new(Point.new(0, 0), Point.new(1, 1)))
    end
  end

  class QuadTileTest < Test::Unit::TestCase
    def test_initialize
      t = QuadTile.new(QuadShape.new(Point.new(1, 1), Point.new(5, 5)), QuadTextureMapping.new, 0)
      assert_true(t.eql? QuadShape.new(Point.new(1, 1), Point.new(5, 5)))
      assert_true(t.tex_map.eql? QuadTextureMapping.new)
      assert_equal(t.ttype, 0)
    end

    def test_splitY
      left, right = QuadTile.new(QuadShape.new(Point.new(1, 1), Point.new(5, 5)), QuadTextureMapping.new).splitY 2
      assert_true(left.eql? QuadShape.new(Point.new(1, 1), Point.new(2, 5)))
      assert_true(left.tex_map.eql? QuadShape.new(Point.new(0, 0), Point.new(0.25, 1)))
      assert_true(right.eql? QuadShape.new(Point.new(2, 1), Point.new(5, 5)))
      assert_true(right.tex_map.eql? QuadShape.new(Point.new(0.25, 0), Point.new(1, 1)))
      left, right = QuadTile.new(QuadShape.new(Point.new(1, 1), Point.new(5, 5)), QuadTextureMapping.new).splitY 0
      assert_nil(left)
      assert_true(right.eql? QuadShape.new(Point.new(1, 1), Point.new(5, 5)))
      assert_true(right.tex_map.eql? QuadTextureMapping.new)
      left, right = QuadTile.new(QuadShape.new(Point.new(1, 1), Point.new(5, 5)), QuadTextureMapping.new).splitY 5
      assert_true(left.eql? QuadShape.new(Point.new(1, 1), Point.new(5, 5)))
      assert_true(left.tex_map.eql? QuadTextureMapping.new)
      assert_nil(right)
    end

    def test_splitX
      up, down = QuadTile.new(QuadShape.new(Point.new(1, 1), Point.new(5, 5)), QuadTextureMapping.new).splitX 2
      assert_true(up.eql? QuadShape.new(Point.new(1, 1), Point.new(5, 2)))
      assert_true(up.tex_map.eql? QuadShape.new(Point.new(0, 0), Point.new(1, 0.25)))
      assert_true(down.eql? QuadShape.new(Point.new(1, 2), Point.new(5, 5)))
      assert_true(down.tex_map.eql? QuadShape.new(Point.new(0, 0.25), Point.new(1, 1)))
      up, down = QuadTile.new(QuadShape.new(Point.new(1, 1), Point.new(5, 5)), QuadTextureMapping.new).splitX 0
      assert_nil(up)
      assert_true(down.eql? QuadShape.new(Point.new(1, 1), Point.new(5, 5)))
      assert_true(down.tex_map.eql? QuadTextureMapping.new)
      up, down = QuadTile.new(QuadShape.new(Point.new(1, 1), Point.new(5, 5)), QuadTextureMapping.new).splitX 5
      assert_true(up.eql? QuadShape.new(Point.new(1, 1), Point.new(5, 5)))
      assert_true(up.tex_map.eql? QuadTextureMapping.new)
      assert_nil(down)
    end

    def test_splitXY
      ne, nw, sw, se = QuadTile.new(QuadShape.new(Point.new(1, 1), Point.new(5, 5)), QuadTextureMapping.new).splitXY Point.new(2, 2)
      assert_true(ne.eql? QuadShape.new(Point.new(2, 1), Point.new(5, 2)))
      assert_true(nw.eql? QuadShape.new(Point.new(1, 1), Point.new(2, 2)))
      assert_true(sw.eql? QuadShape.new(Point.new(1, 2), Point.new(2, 5)))
      assert_true(se.eql? QuadShape.new(Point.new(2, 2), Point.new(5, 5)))
      ne, nw, sw, se = QuadTile.new(QuadShape.new(Point.new(1, 1), Point.new(5, 5)), QuadTextureMapping.new).splitXY Point.new(0, 1)
      assert_nil(ne)
      assert_nil(nw)
      assert_nil(sw)
      assert_true(se.eql? QuadShape.new(Point.new(1, 1), Point.new(5, 5)))
      ne, nw, sw, se = QuadTile.new(QuadShape.new(Point.new(1, 1), Point.new(5, 5)), QuadTextureMapping.new).splitXY Point.new(5, 1)
      assert_nil(ne)
      assert_nil(nw)
      assert_true(sw.eql? QuadShape.new(Point.new(1, 1), Point.new(5, 5)))
      assert_nil(se)
      ne, nw, sw, se = QuadTile.new(QuadShape.new(Point.new(1, 1), Point.new(5, 5)), QuadTextureMapping.new).splitXY Point.new(1, 3)
      assert_true(ne.eql? QuadShape.new(Point.new(1, 1), Point.new(5, 3)))
      assert_nil(nw)
      assert_nil(sw)
      assert_true(se.eql? QuadShape.new(Point.new(1, 3), Point.new(5, 5)))
    end

    def test_split_quad
      t = QuadTile.new(QuadShape.new(Point.new(1, 1), Point.new(5, 5)), QuadTextureMapping.new)
      s = t.split_quad QuadShape.new(Point.new(2, 2), Point.new(3, 3))
      assert_true(s.eql? QuadShape.new(Point.new(2, 2), Point.new(3, 3)))
      assert_true(s.tex_map.eql? QuadShape.new(Point.new(0.25, 0.25), Point.new(0.5, 0.5)))
    end
  end
end
