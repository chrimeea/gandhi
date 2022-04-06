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
      t = QuadTile.new q
      r = QuadTree.new q, 2
      r.insert t
      q = QuadShape.new(Point.new(3, 3), Point.new(7, 7)) 
      s = r.shapes q
      assert_true(s[0].eql? QuadShape.new(Point.new(5, 3), Point.new(7, 5)))
      assert_true(s[0].tex_map.eql? QuadShape.new(Point.new(0.5, 0.3), Point.new(0.7, 0.5)))
      assert_true(s[1].eql? QuadShape.new(Point.new(3, 3), Point.new(5, 5)))
      assert_true(s[1].tex_map.eql? QuadShape.new(Point.new(0.3, 0.3), Point.new(0.5, 0.5)))
      assert_true(s[2].eql? QuadShape.new(Point.new(3, 5), Point.new(5, 7)))
      assert_true(s[2].tex_map.eql? QuadShape.new(Point.new(0.3, 0.5), Point.new(0.5, 0.7)))
      assert_true(s[3].eql? QuadShape.new(Point.new(5, 5), Point.new(7, 7)))
      assert_true(s[3].tex_map.eql? QuadShape.new(Point.new(0.5, 0.5), Point.new(0.7, 0.7)))
      #todo: add more cases after change
    end

    def test_delete
      q = QuadShape.new(Point.new(0, 0), Point.new(10, 10)) 
      t = QuadTile.new q
      r = QuadTree.new q, 2
      r.insert t
      #r.delete t
      #puts r.shapes q
      #todo: fix delete
    end
  end
end
