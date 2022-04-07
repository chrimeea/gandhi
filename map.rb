module Gandhi
  class QuadTree
    def initialize quad, depth, parent = nil
      @quad = quad
      @depth = depth
      @value = Set.new
      @center = quad.center
      @children = nil
      @parent = nil
    end

    def to_s
      "Tree(#{@quad})"
    end

    def eql? other
      @quad.eql? other.quad
    end

    def hash
      @quad.hash
    end

    def insert tile
      quad_tree = find tile
      if quad_tree.bottom?
	quad_tree.value.add tile
      else
	tile.splitXY(quad_tree.center).compact.each { |q| quad_tree.insert q }
      end
    end

    def shapes quad = @quad
      quad_tree = find quad
      if quad_tree.bottom?
        quad_tree.value.to_a.map { |q| q.split_quad(quad.intersection(q)) }.compact
      else
	quad.splitXY(quad_tree.center).compact.map { |q| shapes q }.flatten
      end
    end

    def delete quad = @quad
      quad_tree = find quad
      if quad_tree.quad.eql? quad
        quad_tree.delete_tree
      elsif !quad_tree.bottom?
	quad.splitXY(quad_tree.center).compact.each { |q| quad_tree.delete q }
      end
    end

    protected

    attr_reader :quad, :children, :center, :value

    def delete_tree
	if @parent&.empty?
	  @parent.delete_tree
        else
	  @value = nil
	  @children = nil
	end
    end
    
    def bottom?
      @children.nil?
    end

    def empty?
      @children.all? { |q| q.children.nil? }
    end

    def find shape
      if bottom?
	if @depth > 0
	  split
	else
	  return self
	end
      end
      if shape.intersectsY?(@center.x) || shape.intersectsX?(@center.y)
	return self
      else
	if shape.aboveX? @center.y
	  if shape.leftY? @center.x
	    @children[:nw].find shape
	  else
	    @children[:ne].find shape
	  end
	else
	  if shape.leftY? @center.x
	    @children[:sw].find shape
	  else
	    @children[:se].find shape
	  end
	end
      end
    end

    def split
      top_right_quad, top_left_quad, bottom_left_quad, bottom_right_quad = @quad.splitXY @center
      @children = {}
      @children[:ne] = QuadTree.new(top_right_quad, @depth - 1, self)
      @children[:nw] = QuadTree.new(top_left_quad, @depth - 1, self)
      @children[:sw] = QuadTree.new(bottom_left_quad, @depth - 1, self)
      @children[:se] = QuadTree.new(bottom_right_quad, @depth - 1, self)
    end
  end
end
