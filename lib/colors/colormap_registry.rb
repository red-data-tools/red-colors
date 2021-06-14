module Colors
  module ColormapRegistry
    @registry = {}

    def self.[](name)
      return name if name.is_a?(Colormap)

      name = String.try_convert(name)
      if @registry.key?(name)
        return @registry[name]
      else
        raise ArgumentError, "Unknown colormap name: %p" % name
      end
    end

    def self.register(cmap, name: nil, override_builtin: false)
      case name
      when String, Symbol
        name = name.to_s
      when nil
        name = cmap.name
        if name.nil?
          raise ArgumentError, "`name` cannot be omitted for unnamed colormaps"
        end
      else
        name = String.try_convert(name)
        if name.nil?
          raise ArgumentError, "`name` must be convertible to a String by to_str"
        end
      end

      if @registry.key?(name)
        existing = @registry[name]
        if BUILTIN_COLORMAPS.key?(name)
          unless override_builtin
            raise ArgumentError,
                  "Trying to re-register a builtin colormap: %p" % name
          end
        end
        warn "Trying to re-register the colormap %p which already exists" % name
      end

      unless cmap.is_a?(Colormap)
        raise ArgumentError,
              "Invalid value for registering a colormap (%p for a Colormap)" % cmap
      end

      @registry[name] = cmap
    end

    def self.unregister(name)
      if @registry.key?(name)
        if BUILTIN_COLORMAPS.key?(name)
          raise ArgumentError,
                "Unable to unregister the colormap %p which is a builtin colormap" % name
        end
      else
        @registry.delete(name)
      end
    end
  end
end
