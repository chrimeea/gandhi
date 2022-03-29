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

	class Quad < Shape
		def initialize top_left, bottom_right
			@top_left = top_left
			@bottom_right = bottom_right
			@vertexes = [
				top_left,
				Point.new(top_left.x, bottom_right.y),
				bottom_right,
				Point.new(bottom_right.x, top_left.y)
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
					Quad.new(@top_left, Point.new(x, @bottom_right.y)),
					Quad.new(Point.new(x, @top_left.y), @bottom_right)
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
					Quad.new(@top_left, Point.new(@bottom_right.x, y)),
					Quad.new(Point.new(@top_left.x, y), @bottom_right)
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

	class Triangle < Shape
		def initialize vertex0, vertex1, vertex2
			@vertexes = [vertex0, vertex1, vertex2]
		end
	end

	class TextureCoords
		attr_reader :coords

		def initialize coords
			@coords = coords
		end
	end

	class Tile
		extend Forwardable
		attr_accessor :ttype, :shape, :coords
		def_delegators :@shape, :center, :leftY?, :aboveX, :intersectsY?, :intersectsX?

		def initialize ttype, shape, coords
			@shape = shape
			@ttype = ttype
			@coords = coords
		end

		def splitY x
			@shape.splitY x
			#todo
		end

		def splitX y
			@shape.splitX y
			#todo
		end

		def splitXY x, y
			@shape.splitXY x, y
			#todo
		end
	end
end
