module Colors
  module NamedColors
    class Mapping
      def initialize
        @mapping = {}
        @cache = {}
      end

      def [](name)
        if NamedColors.nth_color?(name)
          cycle = ColorData::DEFAULT_COLOR_CYCLE
          name = cycle[name[1..-1].to_i % cycle.length]
        end
        @cache[name] ||= lookup_no_color_cycle(name)
      end

      private def lookup_no_color_cycle(name)
        case name
        when /\Anone\z/i
          return RGBA.new(0, 0, 0, 0)
        when String
          # nothing to do
        when Symbol
          name = name.to_s
        else
          name = name.to_str
        end
        color = @mapping.fetch(name, name)
        case color
        when /\A#\h+\z/
          case color.length - 1
          when 3, 6
            RGB.parse(color)
          when 4, 8
            RGBA.parse(color)
          else
            raise RuntimeError,
                  "[BUG] Invalid hex string form #{color.inspect} for #{name.inspect}"
          end
        when Array
          case color.length
          when 3
            RGB.new(*color)
          when 4
            RGBA.new(*color)
          else
            raise RuntimeError,
                  "[BUG] Invalid number of color components #{color} for #{name.inspect}"
          end
        else
          color
        end
      end

      def []=(name, value)
        @mapping[name] = value
      ensure
        @cache.clear
      end

      def delete(name)
        @mapping.delete(name)
      ensure
        @cache.clear
      end

      def update(other)
        @mapping.update(other)
      ensure
        @cache.clear
      end
    end

    MAPPING = Mapping.new
    MAPPING.update(ColorData::XKCD_COLORS)
    ColorData::XKCD_COLORS.each do |key, value|
      MAPPING[key.sub("grey", "gray")] = value if key.include? "grey"
    end
    MAPPING.update(ColorData::CSS4_COLORS)
    MAPPING.update(ColorData::TABLEAU_COLORS)
    ColorData::TABLEAU_COLORS.each do |key, value|
      MAPPING[key.sub("gray", "grey")] = value if key.include? "gray"
    end
    MAPPING.update(ColorData::BASE_COLORS)

    def self.[](name)
      MAPPING[name]
    end

    # Return whether `name` is an item in the color cycle.
    def self.nth_color?(name)
      case name
      when String
        # do nothing
      when Symbol
        name = name.to_s
      else
        return false unless name.respond_to?(:to_str)
        name = name.to_str
      end
      name.match?(/\AC\d+\z/)
    end
  end
end
