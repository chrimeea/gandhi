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
      t.height.to_i.times do |i|
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
      load_assets
      generate_map
      @screen = Array.new(@height) { String.new(' ' * @width) }
      @screen_quad = QuadShape.new(Point.new(0, 0), Point.new(@width, @height)).to_raster
      @viewport = QuadShape.new(Point.new(0, 0), Point.new(config['window']['width'], config['window']['height'])).to_raster
      main_window config
      render_tiles
      timer = TkAfter.new(100, -1, proc { play })
      timer.start
    end

    def render_tiles
      tiles = @map_tree.shapes @screen_quad
      tiles.each { |tile| @asset[tile.ttype].render(tile, @screen, @screen_quad.top_left) }
   end
    
    def generate_map
      area_quad = QuadShape.new(Point.new(0, 0), Point.new(@width, @height))
      @map_tree = QuadTree.new(area_quad, 3)
      x = 0 #rand(@width - 4)
      y = 0 #rand(@height - 3)
      tile = QuadTile.new(QuadShape.new(Point.new(x, y), Point.new(x + 4, y + 3)), QuadTextureMapping.new, 1)
      @map_tree.insert tile
    end
    
    def play
      s = []
      @viewport.height.times do |i|
        s[i] = @screen[i + @viewport.top_left.y][@viewport.top_left.x..@viewport.bottom_right.x]
      end
      @label_var.value = s.join("\n")
    end
    
    def load_assets
      @asset = []
      Dir.glob('assets/*.txt') { |filename| @asset[filename[15..-5].to_i] = CharTexture.new(filename) }
    end
    
    def main_window config
      root = TkRoot.new
      root.title = config['window']['title']
      label = TkLabel.new(root) do
        textvariable
        font TkFont.new("#{config['font']['face']} #{config['font']['size']}")
        foreground  'black'
        height config['window']['height']
        width config['window']['width']
        anchor 'nw'
        justify 'left'
        pack("side" => "left",  "padx"=> "0", "pady"=> "0")
      end
      @label_var = TkVariable.new
      label['textvariable'] = @label_var
      root.bind('Left', proc { @viewport = @viewport.translate(-1, 0).to_raster if @viewport.top_left.x > 0 })
      root.bind('Right', proc { @viewport = @viewport.translate(1, 0).to_raster if @viewport.bottom_right.x < @screen[0].size })
      root.bind('Up', proc { @viewport = @viewport.translate(0, -1).to_raster if @viewport.top_left.y > 0 })
      root.bind('Down', proc { @viewport = @viewport.translate(0, 1).to_raster if @viewport.bottom_right.y < @screen.size })
    end

    def run
      Tk.mainloop
    end
  end
end
