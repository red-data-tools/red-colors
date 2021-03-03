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

    XTERM256_THRESHOLD = [0x00, 0x5f, 0x87, 0xaf, 0xd7, 0xff].freeze

    def self.colour_dist_sq(r1, g1, b1, r2, g2, b2)
      (r1 - r2)**2 + (g1 - g2)**2 + (b1 - b2)**2
    end
    
    def self.colour_to_6cube(v)
      return 0 if v < 48
      return 1 if v < 114
      (v - 35) / 40
    end

    # Expects r, g, b as 0..255, returns a value from 16..255
    def self.find_closest(r, g, b)

      ri, gi, bi = [r, g, b].map { |v| (v * 255).to_i }
      
      # Map RGB to 6x6x6 cube
      qr, qg, qb = [ri, gi, bi].map { |v| colour_to_6cube(v) }
      cr, cg, cb = [qr, qg, qb].map { |v| XTERM256_THRESHOLD[v] }
      
      # If we have hit the colour exactly, return early.
      if cr == ri && cg == gi && cb == bi
	return (36 * qr) + (6 * qg) + qb + 16
      end

      # Work out the closest grey (average of RGB).
      grey_avg = (ri + gi + bi) / 3
      grey_idx = (grey_avg > 238) ? 23 : (grey_avg - 3) / 10
      grey = 8 + (10 * grey_idx)

      # Is grey or 6x6x6 colour closest?
      rgb_dist = colour_dist_sq(cr, cg, cb, ri, gi, bi)
      grey_dist = colour_dist_sq(grey, grey, grey, ri, gi, bi)
      if grey_dist < rgb_dist
	232 + grey_idx
      else
	(36 * qr) + (6 * qg) + qb + 16
      end
    end
    
  end
end
