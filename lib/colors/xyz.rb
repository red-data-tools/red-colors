module Colors
  class XYZ < AbstractColor
    include Helper

    EPSILON = (6/29r)**3

    KAPPA = (29/3r)**3

    def initialize(x, y, z)
      @x, @y, @z = canonicalize(x, y, z)
    end

    attr_reader :x, :y, :z

    def components
      [x, y, z]
    end

    def ==(other)
      case other
      when XYZ
        x == other.x && y == other.y && z == other.z
      else
        super
      end
    end

    def to_rgb
      RGB.new(*rgb_components)
    end

    def rgb_components
      Convert.xyz_to_rgb(x, y, z)
    end

    def luv_components(wp)
      yy = y/wp.y
      uu, vv = uv_values
      l = if yy <= EPSILON
            KAPPA * yy
          else
            116 * Math.cbrt(yy).to_r - 16
          end
      if l <= 1e-8
        u = v = 0r
      else
        wp_u, wp_v = wp.uv_values
        u = 13*l*(uu - wp_u)
        v = 13*l*(vv - wp_v)
      end
      [l, u, v]
    end

    def uv_values
      d = x + 15*y + 3*z
      return [0r, 0r] if d == 0
      u = 4*x / d
      v = 9*y / d
      [u, v]
    end

    private def canonicalize(x, y, z)
      [
        Rational(x),
        Rational(y),
        Rational(z)
      ]
    end
  end
end
