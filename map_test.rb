module Gandhi
  class QuadTreeTest < Test::Unit::TestCase
    def test_eql?
      assert_true(QuadTree.new(QuadShape.new(Point.new(1, 1), Point.new(5, 5)), 1).eql? QuadTree.new(QuadShape.new(Point.new(1, 1), Point.new(5, 5)), 1))
      assert_false(QuadTree.new(QuadShape.new(Point.new(2, 1), Point.new(5, 5)), 1).eql? QuadTree.new(QuadShape.new(Point.new(1, 1), Point.new(5, 5)), 1))
    end

    def test_hash
      assert_equal(QuadTree.new(QuadShape.new(Point.new(1, 1), Point.new(5, 5)), 1).hash, QuadTree.new(QuadShape.new(Point.new(1, 1), Point.new(5, 5)), 1).hash)
      assert_not_equal(QuadTree.new(QuadShape.new(Point.new(1, 1), Point.new(5, 5)), 1).hash, QuadTree.new(QuadShape.new(Point.new(1, 1), Point.new(5, 4)), 1).hash)
    end

    def test_insert
      q = QuadShape.new(Point.new(0, 0), Point.new(10, 10)) 
      r = QuadTree.new q, 2
      r.insert QuadTile.new q
      s = r.shapes QuadShape.new(Point.new(3, 3), Point.new(7, 7))
      assert_equal(s.size, 4)
      assert_true(s[0].eql? QuadShape.new(Point.new(5, 3), Point.new(7, 5)))
      assert_true(s[0].tex_map.eql? QuadShape.new(Point.new(0.5, 0.3), Point.new(0.7, 0.5)))
      assert_true(s[1].eql? QuadShape.new(Point.new(3, 3), Point.new(5, 5)))
      assert_true(s[1].tex_map.eql? QuadShape.new(Point.new(0.3, 0.3), Point.new(0.5, 0.5)))
      assert_true(s[2].eql? QuadShape.new(Point.new(3, 5), Point.new(5, 7)))
      assert_true(s[2].tex_map.eql? QuadShape.new(Point.new(0.3, 0.5), Point.new(0.5, 0.7)))
      assert_true(s[3].eql? QuadShape.new(Point.new(5, 5), Point.new(7, 7)))
      assert_true(s[3].tex_map.eql? QuadShape.new(Point.new(0.5, 0.5), Point.new(0.7, 0.7)))
      q = QuadShape.new(Point.new(0, 0), Point.new(10, 10)) 
      r = QuadTree.new q, 1
      r.insert QuadTile.new QuadShape.new(Point.new(1, 6), Point.new(2, 7))
      r.insert QuadTile.new QuadShape.new(Point.new(1, 7), Point.new(2, 8))
      assert_empty(r.shapes QuadShape.new(Point.new(0, 0), Point.new(5, 5)))
      s = r.shapes(QuadShape.new(Point.new(0, 5), Point.new(5, 10)))
      assert_equal(s.size, 2)
      assert_true(s[0].eql? QuadShape.new(Point.new(1, 6), Point.new(2, 7)))
      assert_true(s[0].tex_map.eql? QuadShape.new(Point.new(0, 0), Point.new(1, 1)))
      assert_true(s[1].eql? QuadShape.new(Point.new(1, 7), Point.new(2, 8)))
      assert_true(s[1].tex_map.eql? QuadShape.new(Point.new(0, 0), Point.new(1, 1)))
      assert_empty(r.shapes QuadShape.new(Point.new(5, 0), Point.new(10, 5)))
      assert_empty(r.shapes QuadShape.new(Point.new(5, 5), Point.new(10, 10)))
    end

    def test_free
      q = QuadShape.new(Point.new(0, 0), Point.new(10, 10)) 
      r = QuadTree.new q, 1
      t = QuadTile.new q
      r.insert t
      r.free QuadShape.new(Point.new(0, 0), Point.new(6, 6))
      s = r.shapes
      assert_equal(s.size, 3)
      assert_true(s[0].eql? QuadShape.new(Point.new(5, 0), Point.new(10, 5)))
      assert_true(s[1].eql? QuadShape.new(Point.new(0, 5), Point.new(5, 10)))
      assert_true(s[2].eql? QuadShape.new(Point.new(5, 5), Point.new(10, 10)))
      q = QuadShape.new(Point.new(0, 0), Point.new(10, 10)) 
      r = QuadTree.new q, 3
      t = QuadTile.new q
      r.insert t
      assert_equal(r.shapes.size, 64)
      r.free t
      assert_empty(r.shapes)
      q = QuadShape.new(Point.new(0, 0), Point.new(10, 10)) 
      r = QuadTree.new q, 2
      t = QuadTile.new q
      r.insert t
      assert_equal(r.shapes.size, 16)
      r.free QuadShape.new(Point.new(2.5, 2.5), Point.new(7.5, 7.5))
      assert_empty(r.shapes QuadShape.new(Point.new(2.5, 2.5), Point.new(7.5, 7.5)))
      s = r.shapes
      assert_equal(s.size, 12)
      assert_true(s[0].eql? QuadShape.new(Point.new(7.5, 0), Point.new(10, 2.5)))
      assert_true(s[1].eql? QuadShape.new(Point.new(5, 0), Point.new(7.5, 2.5)))
      assert_true(s[2].eql? QuadShape.new(Point.new(7.5, 2.5), Point.new(10, 5)))
      assert_true(s[3].eql? QuadShape.new(Point.new(2.5, 0), Point.new(5, 2.5)))
      assert_true(s[4].eql? QuadShape.new(Point.new(0, 0), Point.new(2.5, 2.5)))
      assert_true(s[5].eql? QuadShape.new(Point.new(0, 2.5), Point.new(2.5, 5)))
      assert_true(s[6].eql? QuadShape.new(Point.new(0, 5), Point.new(2.5, 7.5)))
      assert_true(s[7].eql? QuadShape.new(Point.new(0, 7.5), Point.new(2.5, 10)))
      assert_true(s[8].eql? QuadShape.new(Point.new(2.5, 7.5), Point.new(5, 10)))
      assert_true(s[9].eql? QuadShape.new(Point.new(7.5, 5), Point.new(10, 7.5)))
      assert_true(s[10].eql? QuadShape.new(Point.new(5, 7.5), Point.new(7.5, 10)))
      assert_true(s[11].eql? QuadShape.new(Point.new(7.5, 7.5), Point.new(10, 10)))
    end
  end
end
