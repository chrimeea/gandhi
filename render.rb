# frozen_string_literal: true

module Gandhi
  class UserInterface
    def initialize
      config = YAML.load_file('config.yml')
      load_assets
      main_window config['ui']
      timer = TkAfter.new(1000, -1, proc { play })
      timer.start
    end

    def play
      @resultsVar.value = @asset[1]
    end
    
    def load_assets
      @asset = []
      Dir.glob('assets/*.txt') { |filename| @asset[filename[15..-5].to_i] = File.read(filename) }
    end
    
    def main_window ui_config
      root = TkRoot.new
      root.geometry("#{ui_config['width']}x#{ui_config['height']}")
      root.title = ui_config['title']
      screen = TkLabel.new(root) do
        textvariable
        font TkFont.new(ui_config['font'])
        foreground  'black'
        height ui_config['height']
        width ui_config['width']
        anchor 'nw'
        justify 'left'
        pack("side" => "left",  "padx"=> "0", "pady"=> "0")
      end
      @resultsVar = TkVariable.new
      screen['textvariable'] = @resultsVar
    end

    def run
      Tk.mainloop
    end
  end
end
