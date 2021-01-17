module Colors
  class Xterm256 < AbstractColor
    include Helper

    def initialize(code)
      unless 16 <= code && code <= 255
        raise ArgumentError, "code should be in 16..255, but #{code} is given"
      end
      @code = code
    end

    attr_reader :code

    def ==(other)
      case other
      when Xterm256
        code == other.code
      else
        super
      end
    end

    def to_rgb_components
      if code < 232
        x = code - 16
        x, b = x.divmod(6)
        r, g = x.divmod(6)
        r = 40*r + 55 if r > 0
        g = 40*g + 55 if g > 0
        b = 40*b + 55 if b > 0
        [
          canonicalize_component_from_integer(r, :r),
          canonicalize_component_from_integer(g, :r),
          canonicalize_component_from_integer(b, :r)
        ]
      else
        grey = to_grey_level
        [grey, grey, grey]
      end
    end

    def to_grey_level
      if code < 232
        r, g, b = to_rgb_components
        x, y, z = Convet.rgb_to_xyz(r, g, b)
      else
        grey = 10*(code - 232) + 8
        canonicalize_component_from_integer(grey, :grey)
      end
    end

    def to_rgb
      RGB.new(*to_rgb_components)
    end
  end
end
