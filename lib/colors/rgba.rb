module Colors
  class RGBA < RGB
    def self.parse(hex_string)
      error_message = "must be a hexadecimal string of " +
                      "`#rrggbbaa`, `#rgba`, `#rrggbb` or `#rgb` form"
      unless hex_string.respond_to?(:to_str)
        raise ArgumentError, "#{error_message}: #{hex_string.inspect}"
      end

      hex_string = hex_string.to_str
      hexes = hex_string.match(/\A#(\h+)\z/) { $1 }
      case hexes&.length
      when 3  # rgb
        r, g, b = hexes.scan(/\h/).map {|h| h.hex * 17 }
        new(r, g, b, 255)
      when 6  # rrggbb
        r, g, b = hexes.scan(/\h{2}/).map(&:hex)
        new(r, g, b, 255)
      when 4 # rgba
        r, g, b, a = hexes.scan(/\h/).map {|h| h.hex * 17 }
        new(r, g, b, a)
      when 8 # rrggbbaa
        r, g, b, a = hexes.scan(/\h{2}/).map(&:hex)
        new(r, g, b, a)
      else
        raise ArgumentError, "#{error_message}: #{hex_string.inspect}"
      end
    end

    def initialize(r, g, b, a)
      @r, @g, @b, @a = canonicalize(r, g, b, a)
    end

    include AlphaComponent

    def components
      [r, g, b, a]
    end

    def ==(other)
      case other
      when RGBA
        r == other.r && g == other.g && b == other.b && a == other.a
      when RGB
        r == other.r && g == other.g && b == other.b && a == 1r
      else
        super
      end
    end

    def desaturate(factor)
      to_hsla.desaturate(factor).to_rgba
    end

    def to_rgb
      if a == 1r
        RGB.new(r, g, b)
      else
        raise NotImplementedError,
              "Unable to convert non-opaque RGBA to RGB"
      end
    end

    def to_rgba
      self
    end

    def to_hsl
      if a == 1r
        super
      else
        raise NotImplementedError,
              "Unable to convert non-opaque RGBA to RGB"
      end
    end

    def to_hsla
      HSLA.new(*hsl_components, a)
    end

    private def canonicalize(r, g, b, a)
      if [r, g, b, a].map(&:class) == [Integer, Integer, Integer, Integer]
        canonicalize_from_integer(r, g, b, a)
      else
        [
          canonicalize_component_to_rational(r, :r),
          canonicalize_component_to_rational(g, :g),
          canonicalize_component_to_rational(b, :b),
          canonicalize_component_to_rational(a, :a)
        ]
      end
    end

    private def canonicalize_from_integer(r, g, b, a)
      check_type(r, Integer, :r)
      check_type(g, Integer, :g)
      check_type(b, Integer, :b)
      check_type(a, Integer, :a)
      [
        canonicalize_component_from_integer(r, :r),
        canonicalize_component_from_integer(g, :g),
        canonicalize_component_from_integer(b, :b),
        canonicalize_component_from_integer(a, :a)
      ]
    end
  end
end
