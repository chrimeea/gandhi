module Gandhi
  class Point
    attr_accessor :x, :y

    def initialize x, y
      @x = x.to_f
      @y = y.to_f
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
      @bottom_right.x <= x
    end

    def aboveX? y
      @bottom_right.y <= y
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
      top_left_quad, bottom_left_quad = left_quad&.splitX center.y
      top_right_quad, bottom_right_quad = right_quad&.splitX center.y
      [top_right_quad, top_left_quad, bottom_left_quad, bottom_right_quad]
    end
  end

  class QuadTextureMapping < QuadShape
    def initialize
      super Point.new(0, 0), Point.new(1, 1)
    end

    def self.convertXToTex quad, x
      (x - quad.top_left.x) / (quad.bottom_right.x - quad.top_left.x)
    end
    
    def self.convertYToTex quad, y
      (y - quad.top_left.y) / (quad.bottom_right.y - quad.top_left.y)
    end
    
    def self.convertXYToTex quad, point
      Point.new convertXToTex(quad, point.x), convertYToTex(quad, point.y)
    end
  end

  class Tile
    extend Forwardable
    attr_reader :ttype, :shape, :tex_map
    def_delegators :@shape, :center, :leftY?, :aboveX?, :intersectsY?, :intersectsX?

    def initialize shape, tex_map, ttype = nil
      @ttype = ttype
      @shape = shape
      @tex_map = tex_map
    end

    def splitY x
      left_shape, right_shape = @shape.splitY x
      left_tex, right_tex = @tex_map.splitY QuadTextureMapping.convertXToTex(@shape, x)
      [
        Tile.new(left_shape, left_tex),
        Tile.new(right_shape, right_tex)
      ]
    end

    def splitX y
      above_shape, below_shape = @shape.splitX y
      above_tex, below_tex = @tex_map.splitX QuadTextureMapping.convertYToTex(@shape, y)
      [
        Tile.new(above_shape, above_tex),
        Tile.new(below_shape, below_tex)
      ]
    end

    def splitXY center
      ne_shape, nw_shape, sw_shape, se_shape = @shape.splitXY center
      ne_tex, nw_tex, sw_tex, se_tex = @tex_map.splitXY QuadTextureMapping.convertXYToTex(@shape, center)
      [
        Tile.new(ne_shape, ne_tex),
        Tile.new(nw_shape, nw_tex),
        Tile.new(sw_shape, sw_tex),
        Tile.new(se_shape, se_tex)
      ]
    end

    def to_s
      "Tile(#{@shape}:#{@tex_map})"
    end
  end
end
