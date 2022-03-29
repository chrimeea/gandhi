module Gandhi
	class Point
		attr_accessor :x, :y

		def initialize x, y
			@x = x
			@y = y
		end

		def translate x, y
			Point.new @x + x, @y + y
		end

		def eql? other
			x == other.x and y == other.y
		end

		def hash
			[x, y].hash
		end

		def to_s
			"Point(#{@x}, #{@y})"
		end
	end

	class Shape
		attr_reader :vertexes, :center

		def initialize vertexes
			@vertexes = vertexes
		end

		def eql? other
			@vertexes == other.vertexes
		end

		def hash
			@vertexes.hash
		end
	end

	class QuadShape < Shape
		attr_reader :top_left, :bottom_right

		def initialize top_left, bottom_right
			@top_left = top_left
			@bottom_right = bottom_right
			@vertexes = [
				Point.new(bottom_right.x, top_left.y),
				top_left,
				Point.new(top_left.x, bottom_right.y),
				bottom_right
			]
		end

		def to_s
			"Quad(#{@top_left}, #{@bottom_right})"
		end

		def eql? other
			@vertexes.eql? other.vertexes
		end

		def hash
			@vertexes.hash
		end

		def center
			Point.new(
				(@top_left.x + @bottom_right.x) / 2,
				(@top_left.y + @bottom_right.y) / 2
			)
		end

		def leftY? x
			@bottom_right.x < x
		end

		def aboveX? y
			@bottom_right.y < y
		end

		def intersectsY? x
			@top_left.x < x and @bottom_right.x > x
		end

		def intersectsX? y
			@top_left.y < y and @bottom_right.y > y
		end

		def splitY x
			if intersectsY? x
				[
					QuadShape.new(@top_left, Point.new(x, @bottom_right.y)),
					QuadShape.new(Point.new(x, @top_left.y), @bottom_right)
				]
			elsif leftY? x
				[self, nil]
			else
				[nil, self]
			end
		end

		def splitX y
			if intersectsX? y
				[
					QuadShape.new(@top_left, Point.new(@bottom_right.x, y)),
					QuadShape.new(Point.new(@top_left.x, y), @bottom_right)
				]
			elsif aboveX? y
				[self, nil]
			else
				[nil, self]
			end
		end

		def splitXY center
			left_quad, right_quad = splitY center.x
			top_left_quad, bottom_left_quad = left_quad.splitX center.y
			top_right_quad, bottom_right_quad = right_quad.splitX center.y
			[top_right_quad, top_left_quad, bottom_left_quad, bottom_right_quad]
		end
	end

	class QuadTextureMapping < QuadShape
		attr_reader :shape

		def initialize quad
			super Point.new(0, 0), Point.new(1, 1)
			@shape = quad
		end

		def convertXToTex x
			(x - @shape.top_left.x) / (@shape.bottom_right.x - @shape.top_left.x)
		end

		def convertYToTex y
			(y - @shape.top_left.y) / (@shape.bottom_right.y - @shape.top_left.y)
		end
	end

	class Tile
		extend Forwardable
		attr_accessor :ttype, :tex_map
		def_delegators :@tex_map.shape, :center, :leftY?, :aboveX, :intersectsY?, :intersectsX?

		def initialize ttype, tex_map
			@ttype = ttype
			@tex_map = tex_map
		end

		def splitY x
			@tex_map.shape.splitY x
			@tex_map.splitY @tex_map.convertXToTex(x)
		end

		def splitX y
			@tex_map.shape.splitX y
			@tex_map.splitX @tex_map.convertYToTex(y)
		end

		def splitXY x, y
			@tex_map.shape.splitXY x, y
			@tex_map.splitXY @tex_map.convertXToTex(x), @tex_map.convertYToTex(y)
		end
	end
end
