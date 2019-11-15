module Colors
  class XYY < AbstractColor
    include Helper

    def initialize(x, y, large_y)
      @x, @y, @large_y = canonicalize(x, y, large_y)
    end

    attr_reader :x, :y, :large_y

    def components
      [x, y, large_y]
    end

    def ==(other)
      case other
      when XYY
        x == other.x && y == other.y && large_y == other.large_y
      else
        super
      end
    end

    def to_rgb
      to_xyz.to_rgb
    end

    def rgb_components
      to_xyz.rgb_components
    end

    def luv_components(wp)
      to_xyz.luv_components(wp)
    end

    def to_xyz
      large_x = large_y*x/y
      large_z = large_y*(1 - x - y)/y
      XYZ.new(large_x, large_y, large_z)
    end

    private def canonicalize(x, y, large_y)
      [
        Rational(x),
        Rational(y),
        Rational(large_y)
      ]
    end
  end
end
