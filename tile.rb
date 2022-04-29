# frozen_string_literal: true

module Gandhi
  class Point
    attr_accessor :x, :y

    def initialize x, y
      @x = x.to_f
      @y = y.to_f
      freeze
    end

    def translate x, y
      Point.new @x + x, @y + y
    end
    
    def eql? other
      x == other.x && y == other.y
    end

    def hash
      [x, y].hash
    end

    def to_s
      "Point(#{@x}, #{@y})"
    end
  end

  class RasterPoint < Point
    def initialize x, y
      @x = x.round.to_i
      @y = y.round.to_i
      freeze
    end

    def translate x, y
      RasterPoint.new @x + x, @y + y
    end
  end

  class Shape
    attr_reader :vertexes

    def initialize vertexes
      @vertexes = vertexes
      freeze
    end

    def eql? other
      @vertexes.eql? other.vertexes
    end

    def hash
      @vertexes.hash
    end

    def translate x, y
      Shape.new(@vertexes.map { |v| v.translate x, y })
    end

    def to_raster
      Shape.new(@vertexes.map { |v| RasterPoint.new v.x, v.y })
    end
  end

  class QuadShape < Shape
    attr_reader :top_left, :bottom_right

    def initialize top_left, bottom_right
      @top_left = top_left
      @bottom_right = bottom_right
      freeze
    end

    def to_s
      "Quad(#{@top_left}, #{@bottom_right})"
    end

    def eql? other
      top_left.eql?(other.top_left) && bottom_right.eql?(other.bottom_right)
    end

    def hash
      [top_left, bottom_right].hash
    end

    def translate x, y
      QuadShape.new(@top_left.translate(x, y), @bottom_right.translate(x, y))
    end

    def to_raster
      QuadShape.new(RasterPoint.new(@top_left.x, @top_left.y), RasterPoint.new(@bottom_right.x, @bottom_right.y))
    end

    def center
      Point.new(
	(@top_left.x + @bottom_right.x) / 2,
	(@top_left.y + @bottom_right.y) / 2
      )
    end

    def width
      @bottom_right.x - @top_left.x
    end

    def height
      @bottom_right.y - @top_left.y
    end
    
    def leftY? x
      @bottom_right.x <= x
    end

    def aboveX? y
      @bottom_right.y <= y
    end

    def intersectsY? x
      @top_left.x < x && @bottom_right.x > x
    end

    def intersectsX? y
      @top_left.y < y && @bottom_right.y > y
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

    def convertX quad, x
      (x - @top_left.x) * quad.width / width + quad.top_left.x
    end
    
    def convertY quad, y
      (y - @top_left.y) * quad.height / height + quad.top_left.y
    end
    
    def convertXY quad, point
      Point.new convertX(quad, point.x), convertY(quad, point.y)
    end

    def split_quad quad
      quad
    end

    def intersection quad
      if eql? quad
        quad
      else
        intersection_partial(quad) || quad.intersection_partial(self)
      end
    end
    
    protected
    
    def intersection_partial quad
      top_left_x = intersectsX? quad.top_left.y
      top_left_y = intersectsY? quad.top_left.x
      bottom_right_x = intersectsX? quad.bottom_right.y
      bottom_right_y = intersectsY? quad.bottom_right.x
      top_left_in = top_left_x && top_left_y
      top_right_in = top_left_x && bottom_right_y
      bottom_left_in = bottom_right_x && top_left_y
      bottom_right_in = bottom_right_x && bottom_right_y
      if top_left_in
        if top_right_in
          if bottom_left_in # (A, B, C, D)
            return quad
          else # (A, B)
            return QuadShape.new(quad.top_left, Point.new(quad.bottom_right.x, @bottom_right.y))
          end
        elsif bottom_left_in # (A, D)
          return QuadShape.new(quad.top_left, Point.new(@bottom_right.x, quad.bottom_right.y))
        else # (A)
          return QuadShape.new(quad.top_left, @bottom_right)
        end
      elsif top_right_in
        if bottom_right_in # (B, C)
          return QuadShape.new(Point.new(@top_left.x, quad.top_left.y), quad.bottom_right)
        else # (B)
          return QuadShape.new(Point.new(@top_left.x, quad.top_left.y), Point.new(quad.bottom_right.x, @bottom_right.y))
        end
      elsif bottom_right_in
        if bottom_left_in # (D, C)
          return QuadShape.new(Point.new(quad.top_left.x, @top_left.y), quad.bottom_right)
        else # (C)
          return QuadShape.new(@top_left, quad.bottom_right)
        end
      elsif bottom_left_in # (D)
        return QuadShape.new(Point.new(quad.top_left.x, @top_left.y), Point.new(@bottom_right.x, quad.bottom_right.y))
      else
        return nil
      end
    end
  end
  
  class QuadTextureMapping < QuadShape
    def initialize
      super Point.new(0, 0), Point.new(1, 1)
    end
  end

  class QuadTile < QuadShape
    attr_reader :ttype, :tex_map

    def initialize shape, tex_map = QuadTextureMapping.new, ttype = nil
      @ttype = ttype
      @tex_map = tex_map
      super(shape.top_left, shape.bottom_right)
    end

    def splitY x
      left_shape, right_shape = super x
      left_tex, right_tex = @tex_map.splitY convertX(@tex_map, x)
      [
        if left_shape then QuadTile.new(left_shape, left_tex, ttype) else nil end,
        if right_shape then QuadTile.new(right_shape, right_tex, ttype) else nil end
      ]
    end

    def splitX y
      above_shape, below_shape = super y
      above_tex, below_tex = @tex_map.splitX convertY(@tex_map, y)
      [
        if above_shape then QuadTile.new(above_shape, above_tex, ttype) else nil end,
        if below_shape then QuadTile.new(below_shape, below_tex, ttype) else nil end
      ]
    end

    def splitXY center
      ne_shape, nw_shape, sw_shape, se_shape = super center
      ne_tex, nw_tex, sw_tex, se_tex = @tex_map.splitXY convertXY(@tex_map, center)
      [
        if ne_shape then QuadTile.new(ne_shape, ne_tex, ttype) else nil end,
        if nw_shape then QuadTile.new(nw_shape, nw_tex, ttype) else nil end,
        if sw_shape then QuadTile.new(sw_shape, sw_tex, ttype) else nil end,
        if se_shape then QuadTile.new(se_shape, se_tex, ttype) else nil end
      ]
    end

    def split_quad quad
      return nil if quad.nil?
      QuadTile.new(quad, QuadShape.new(convertXY(@tex_map, quad.top_left), convertXY(@tex_map, quad.bottom_right)), ttype)
    end

    def to_s
      "QuadTile(#{super}:#{@tex_map})"
    end
  end
end
