require_relative "colors/alpha_component"
require_relative "colors/convert"
require_relative "colors/helper"

require_relative "colors/abstract_color"
require_relative "colors/hsl"
require_relative "colors/hsla"
require_relative "colors/husl"
require_relative "colors/rgb"
require_relative "colors/rgba"
require_relative "colors/xterm256"
require_relative "colors/xyy"
require_relative "colors/xyz"

require_relative "colors/color_data"
require_relative "colors/named_colors"

module Colors
  # ITU-R BT.709 D65 white point
  # See https://en.wikipedia.org/wiki/Rec._709 for details
  WHITE_POINT_D65 = Colors::XYY.new(0.3127r, 0.3290r, 1r).to_xyz

  def self.desaturate(c, factor)
    case c
    when String
      c = NamedColors[c]
    end
    c.desaturate(factor)
  end

  def self.[](name)
    NamedColors[name]
  end
end
