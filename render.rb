# frozen_string_literal: true

module Gandhi
  class CharTexture
    def initialize filename
      @data = File.read(filename).split "\n"
      @width = @data[0].size
      @height = @data.size
    end

    def render tile, screen
      quad = QuadShape.new(
	Point.new(tile.tex_map.top_left.x * @width, tile.tex_map.top_left.y * @height),
	Point.new(tile.tex_map.bottom_right.x * @width, tile.tex_map.bottom_right.y * @height)
      )
      tile.height.round.times do |i|
        screen[i + tile.top_left.y.round][tile.top_left.x.round..tile.bottom_right.x.round] \
        = @data[i + quad.top_left.y.round][quad.top_left.x.round..quad.bottom_right.x.round]
      end
    end
  end
  
  class UserInterface
    def initialize
      config = YAML.load_file('config.yml')
      @height = config['window']['height']
      @width = config['window']['width']
      load_assets
      generate_map
      @screen = Array.new(@height) { String.new(' ' * @width) }
      main_window config
      render_tiles
      timer = TkAfter.new(1000, -1, proc { play })
      timer.start
    end

    def render_tiles
      tiles = @map_tree.shapes QuadShape.new(Point.new(0, 0), Point.new(@width, @height))
      tiles.each { |tile| @asset[tile.ttype].render(tile, @screen) }
    end
    
    def generate_map
      area_quad = QuadShape.new(Point.new(0, 0), Point.new(@width, @height))
      @map_tree = QuadTree.new(area_quad, 3)
      x = rand(@width - 4)
      y = rand(@height - 3)
      tile = QuadTile.new(QuadShape.new(Point.new(x, y), Point.new(x + 4, y + 3)), QuadTextureMapping.new, 1)
      @map_tree.insert tile
    end
    
    def play
      @label_var.value = @screen.join("\n")
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
      root.bind('Left', proc { p 'LEFT'})
      root.bind('Right', proc { p 'RIGHT'})
      root.bind('Up', proc { p 'UP'})
      root.bind('Down', proc { p 'DOWN'})
    end

    def run
      Tk.mainloop
    end
  end
end
