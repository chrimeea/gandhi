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
			if quad_tree.children.nil?
				quad_tree.value.add tile
			else
				quad.splitXY(quad_tree.center).each { |q| quad_tree.insert q }
			end
		end

		def empty?
			@children.all? { |q| q.children.nil?  }
		end

		def delete quad = @quad
			quad_tree = find quad
			if quad_tree.quad == quad
				quad_tree.value = nil
				quad_tree.children = nil
				parent = quad_tree.parent
				if parent and parent.empty?
					parent.delete
				end
			else
				quad.splitXY(quad_tree.center).each { |q| quad_tree.delete q }
			end
		end

		def find shape
			if @children.nil?
				if @depth > 0
					split
				else
					return self
				end
			end
			if shape.intersectsY?(@center.x) or shape.intersectsX?(@center.y)
				return self
			else
				if shape.aboveX? @center.x
					if shape.leftY? @center.y
						@children[:nw].find shape
					else
						@children[:ne].find shape
					end
				else
					if shape.leftY? @center.y
						@children[:sw].find shape
					else
						@children[:se].find shape
					end
				end
			end
		end

		protected

		attr_reader :quad, :children, :center, :value

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
