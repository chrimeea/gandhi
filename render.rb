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
      t = tile.to_raster.translate(-screen_top_left.x, -screen_top_left.y)
      t.height.times do |i|
        screen.render(
          i + t.top_left.y,
          t.top_left.x...t.bottom_right.x,
          @data[i + q.top_left.y][q.top_left.x...q.bottom_right.x]
        )
      end
    end
  end
  
  class Screen
    attr_reader :quad

    def initialize quad
      @quad = quad.to_raster
      @screen = Array.new(quad.height) { String.new(' ' * quad.width) }
    end

    def render line, cols, data
      @screen[line][cols] = data
    end

    def move_left width
      if width > 0
        p "LOAD LEFT #{width}"
        @quad.height.times do |i|
          @screen[i][width..] = @screen[i][...-width]
          @screen[i][...width] = ' ' * width
        end
        @quad = @quad.translate -width, 0
        QuadShape.new(@quad.top_left, Point.new(@quad.top_left.x + width, @quad.bottom_right.y))
      end
    end

    def move_right width
      if width > 0
        p "LOAD RIGHT #{width}"
        @quad.height.times do |i|
          @screen[i][...-width] = @screen[i][width..]
          @screen[i][-width..] = ' ' * width
        end
        @quad = @quad.translate width, 0
        QuadShape.new(Point.new(@quad.bottom_right.x - width, @quad.top_left.y), @quad.bottom_right)
      end
    end

    def move_up height
      if height > 0
        p "LOAD UP #{height}"
        @screen[height..] = @screen[...-height]
        @screen[...height] = Array.new(height) { String.new(' ' * @quad.width) }
        @quad = @quad.translate 0, -height
        QuadShape.new(@quad.top_left, Point.new(@quad.bottom_right.x, @quad.top_left.y + height))
      end
    end

    def move_down height
      if height > 0
        p "LOAD DOWN #{height}"
        @screen[...-height] = @screen[height..]
        @screen[-height..] = Array.new(height) { String.new(' ' * @quad.width) }
        @quad = @quad.translate 0, height
        QuadShape.new(Point.new(@quad.top_left.x, @quad.bottom_right.y - height), @quad.bottom_right)
      end
    end

    def view quad
      s = []
      quad.height.times do |i|
        s[i] = @screen[i + quad.top_left.y - @quad.top_left.y][(quad.top_left.x - @quad.top_left.x)..(quad.bottom_right.x - @quad.top_left.x)]
      end
      s.join("\n")
    end
  end

  class UserInterface
    def initialize
      config = YAML.load_file('config.yml')
      @map_quad = QuadShape.new(Point.new(0, 0), Point.new(config['map']['width'], config['map']['height'])).to_raster
      @buffer_width = config['map']['buffer']['width']
      @buffer_height = config['map']['buffer']['height']
      load_assets
      generate_map
      @screen = Screen.new QuadShape.new(Point.new(0, 0), Point.new(config['map']['memory']['width'], config['map']['memory']['height']))
      x = 23
      y = 23
      @viewport_quad = QuadShape.new(Point.new(0 + x, 0 + y), Point.new(config['window']['width'] + x, config['window']['height'] + y)).to_raster
      main_window config
      render_tiles @screen.quad
      timer = TkAfter.new(100, -1, proc { play })
      timer.start
    end

    def render_tiles quad
      @map_tree.shapes(quad).each do |tile|
        @asset[tile.ttype].render(tile, @screen, quad.top_left)
      end
    end

    def generate_map
      @map_tree = QuadTree.new(@map_quad, 3)
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
      @label_var.value = @screen.view(@viewport_quad)
    end
    
    def load_assets
      @asset = []
      Dir.glob('assets/*.txt') { |filename| @asset[filename[15..-5].to_i] = CharTexture.new(filename) }
    end

    def move_viewport_left
      if @viewport_quad.top_left.x > @map_quad.top_left.x
        if @viewport_quad.top_left.x - @screen.quad.top_left.x <= 0
          render_tiles @screen.move_left([@screen.quad.top_left.x - @map_quad.top_left.x, @buffer_width].min)
        end
        @viewport_quad = @viewport_quad.translate(-1, 0).to_raster
      end
    end

    def move_viewport_right
      if @viewport_quad.bottom_right.x < @map_quad.bottom_right.x
        if @screen.quad.bottom_right.x - @viewport_quad.bottom_right.x <= 0
          render_tiles @screen.move_right([@map_quad.bottom_right.x - @screen.quad.bottom_right.x, @buffer_width].min)
        end
        @viewport_quad = @viewport_quad.translate(1, 0).to_raster
      end
    end
    
    def move_viewport_up
      if @viewport_quad.top_left.y > @map_quad.top_left.y
        if @viewport_quad.top_left.y - @screen.quad.top_left.y <= 0
          render_tiles @screen.move_up([@screen.quad.top_left.y - @map_quad.top_left.y, @buffer_height].min)
        end
        @viewport_quad = @viewport_quad.translate(0, -1).to_raster
      end
    end

    def move_viewport_down
      if @viewport_quad.bottom_right.y < @map_quad.bottom_right.y
        if @screen.quad.bottom_right.y - @viewport_quad.bottom_right.y <= 0
          render_tiles @screen.move_down([@map_quad.bottom_right.y - @screen.quad.bottom_right.y, @buffer_height].min)
        end
        @viewport_quad = @viewport_quad.translate(0, 1).to_raster
      end
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
