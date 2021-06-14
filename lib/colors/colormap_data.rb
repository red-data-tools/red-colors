require "json"
require "pathname"

module Colors
  module ColormapRegistry
    BUILTIN_COLORMAPS = {}
    LUT_SIZE = 512

    top_dir = Pathname.new(__dir__).parent.parent
    @colormaps_dir = top_dir.join("data", "colormaps")

    def self.load_colormap_data(name)
      path = @colormaps_dir.join("#{name}.json")
      json = File.read(path)
      JSON.load(json, nil, symbolize_names: true, create_additions: false)
    end

    def self.register_listed_colormap(name, data=nil)
      data = load_colormap_data(name) if data.nil?
      colors = data.map {|r, g, b| Colors::RGB.new(r, g, b) }
      BUILTIN_COLORMAPS[name] = ListedColormap.new(colors, name: name)
    end

    require_relative "colormap_data/matplotlib_builtin.rb"
    require_relative "colormap_data/seaborn_builtin.rb"

    class << self
      undef load_colormap_data
      undef register_listed_colormap
    end

    # Generate reversed colormaps
    cmaps_r = BUILTIN_COLORMAPS.each_value.map(&:reversed)
    cmaps_r.each do |cmap_r|
      BUILTIN_COLORMAPS[cmap_r.name] = cmap_r
    end

    BUILTIN_COLORMAPS.freeze

    BUILTIN_COLORMAPS.each do |name, cmap|
      @registry[name] = cmap
    end
  end
end
