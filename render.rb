# frozen_string_literal: true

module Gandhi
  class CharTexture
    def initialize filename
      @data = File.read(filename).split "\n"
      @width = @data[0].size
      @height = @data.size
    end

    def render tile, screen, screen_top_left
      q = QuadShape.new(
        Point.new(tile.tex_map.top_left.x * @width, tile.tex_map.top_left.y * @height),
        Point.new(tile.tex_map.bottom_right.x * @width, tile.tex_map.bottom_right.y * @height)
      ).to_raster
      t = tile.to_raster.translate -screen_top_left.x, -screen_top_left.y
      t.height.times do |i|
        screen[i + t.top_left.y][t.top_left.x..t.bottom_right.x] \
        = @data[i + q.top_left.y][q.top_left.x..q.bottom_right.x]
      end
    end
  end
  
  class UserInterface
    def initialize
      config = YAML.load_file('config.yml')
      @height = config['memory']['height']
      @width = config['memory']['width']
      viewport_width = config['window']['width']
      viewport_height = config['window']['height']
      @map_width = config['map']['width']
      @map_height = config['map']['height']
      @buffer_width = (@width - viewport_width) / 2
      @buffer_height = (@height - viewport_height) / 2
      load_assets
      generate_map
      @screen = Array.new(@height) { String.new(' ' * @width) }
      @screen_quad = QuadShape.new(Point.new(0, 0), Point.new(@width, @height)).to_raster
      x = 23
      y = 23
      @viewport = QuadShape.new(Point.new(0 + x, 0 + y), Point.new(viewport_width + x, viewport_height + y)).to_raster
      main_window config
      render_tiles
      timer = TkAfter.new(100, -1, proc { play })
      timer.start
    end

    def render_tiles
      tiles = @map_tree.shapes @screen_quad
      tiles.each { |tile| @asset[tile.ttype].render(tile, @screen, @screen_quad.top_left) }
    end

    def load_screen_left
      if @screen_quad.top_left.x >= @buffer_width
        p 'LOAD LEFT'
        @screen_quad.height.times do |i|
          @screen[i][...-@buffer_width] = @screen[i][@buffer_width..]
        end
        @screen_quad = @screen_quad.translate -@buffer_width, 0
        render_tiles
      end
    end

    def load_screen_right
      if @screen_quad.bottom_right.x <= @map_width - @buffer_width
        p 'LOAD RIGHT'
        @screen_quad.height.times do |i|
          @screen[i][@buffer_width..] = @screen[i][...-@buffer_width]
        end
        @screen_quad = @screen_quad.translate @buffer_width, 0
        render_tiles
      end
    end

    def load_screen_up
      if @screen_quad.top_left.y >= @buffer_height
        p 'LOAD UP'
        @screen[buffer_height..] = @screen[...-buffer_height]
        @screen_quad = @screen_quad.translate 0, -@buffer_height
        render_tiles
      end
    end

    def load_screen_down
      if @screen_quad.bottom_right.y <= @map_height - @buffer_height
        p 'LOAD DOWN'
        @screen[...-buffer_height] = @screen[buffer_height..]
        @screen_quad = @screen_quad.translate 0, @buffer_height
        render_tiles
      end
    end

    def generate_map
      area_quad = QuadShape.new(Point.new(0, 0), Point.new(@width, @height))
      @map_tree = QuadTree.new(area_quad, 3)
      x = 23
      y = 23
      tile = QuadTile.new(QuadShape.new(Point.new(x, y), Point.new(x + 4, y + 3)), QuadTextureMapping.new, 1)
      @map_tree.insert tile
      x = 23 + 48 - 4
      tile = QuadTile.new(QuadShape.new(Point.new(x, y), Point.new(x + 4, y + 3)), QuadTextureMapping.new, 1)
      @map_tree.insert tile
      y = 23 + 48 - 3
      tile = QuadTile.new(QuadShape.new(Point.new(x, y), Point.new(x + 4, y + 3)), QuadTextureMapping.new, 1)
      @map_tree.insert tile
      x = 23
      tile = QuadTile.new(QuadShape.new(Point.new(x, y), Point.new(x + 4, y + 3)), QuadTextureMapping.new, 1)
      @map_tree.insert tile
    end

    def play
      s = []
      @viewport.height.times do |i|
        s[i] = @screen[i + @viewport.top_left.y - @screen_quad.top_left.y][(@viewport.top_left.x - @screen_quad.top_left.x)..(@viewport.bottom_right.x - @screen_quad.top_left.x)]
      end
      @label_var.value = s.join("\n")
    end
    
    def load_assets
      @asset = []
      Dir.glob('assets/*.txt') { |filename| @asset[filename[15..-5].to_i] = CharTexture.new(filename) }
    end

    def move_viewport_left
      if @viewport.top_left.x - @screen_quad.top_left.x <= 0
        load_screen_left
      end
      @viewport = @viewport.translate(-1, 0).to_raster if @viewport.top_left.x > 0
    end

    def move_viewport_right
      if @screen_quad.bottom_right.x - @viewport.bottom_right.x <= 0
        load_screen_right
      end
      @viewport = @viewport.translate(1, 0).to_raster if @viewport.bottom_right.x < @screen[0].size
    end
    
    def move_viewport_up
      if @viewport.top_left.y - @screen_quad.top_left.y <= 0
        load_screen_up
      end
      @viewport = @viewport.translate(0, -1).to_raster if @viewport.top_left.y > 0
    end

    def move_viewport_down
      if @screen_quad.bottom_right.y - @viewport.bottom_right.y <= 0
        load_screen_down
      end
      @viewport = @viewport.translate(0, 1).to_raster if @viewport.bottom_right.y < @screen.size
    end

    def main_window config
      root = TkRoot.new
      root.title = config['window']['title']
      label = TkLabel.new(root) do
        textvariable
        font TkFont.new("#{config['window']['font']['face']} #{config['window']['font']['size']}")
        foreground  'black'
        height config['window']['height']
        width config['window']['width']
        anchor 'nw'
        justify 'left'
        pack("side" => "left",  "padx"=> "0", "pady"=> "0")
      end
      @label_var = TkVariable.new
      label['textvariable'] = @label_var
      root.bind('Left', proc { move_viewport_left })
      root.bind('Right', proc { move_viewport_right })
      root.bind('Up', proc { move_viewport_up })
      root.bind('Down', proc { move_viewport_down })
    end

    def run
      Tk.mainloop
    end
  end
end
