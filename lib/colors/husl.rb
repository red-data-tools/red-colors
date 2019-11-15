module Colors
  # Human-friendly alternative to HSL color space.
  # The definition of HUSL is provided in <http://www.hsluv.org>.
  class HUSL < HSL
    def ==(other)
      case other
      when HUSL
        h == other.h && s == other.s && l == other.l
      else
        other == self
      end
    end

    def desaturate(factor)
      to_rgb.desaturate(factor).to_husl
    end

    def to_husl
      self
    end

    def to_rgb
      RGB.new(*rgb_components)
    end

    def to_xyz
      x, y, z = Convert.lch_to_xyz(*lch_components)
      XYZ.new(x, y, z)
    end

    def rgb_components
      to_xyz.rgb_components
    end

    def lch_components
      l = self.l * 100r
      s = self.s * 100r

      if l > 99.9999999 || l < 1e-8
        c = 0r
      else
        mx = Convert.max_chroma(l, h)
        c = mx / 100r * s
      end

      h = s < 1e-8 ? 0r : self.h

      [l, c, h]
    end
  end
end
