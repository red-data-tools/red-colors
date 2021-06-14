module Colors
  module ColormapRegistry
    BUILTIN_COLORMAPS = {}

    require_relative "colormap_data/matplotlib_builtin.rb"

    BUILTIN_COLORMAPS.freeze

    BUILTIN_COLORMAPS.each do |name, cmap|
      @registry[name] = cmap
    end
  end
end
