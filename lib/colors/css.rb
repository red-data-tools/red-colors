module Colors
  module CSS
    # Factory method for generating RGB/RGBA/HSL/HSLA Objects.
    # Parsing based on spec https://www.w3.org/TR/css-color-3 ; section 4.2
    def self.parse(css_string)
      error_message = "must be a string of `rgb(rr,gg,bb)`, `rgba(rr,gg,bb,aa)`, `hsl(hh,ss,ll)`, or `hsla(hh,ss,ll,aa)` form"
      unless css_string.respond_to?(:to_str)
        raise ArgumentError, "#{error_message}: #{css_string.inspect}"
      end

      css_string = css_string.to_str.strip

      matcher = /\A((?:rgb|hsl)a?)\(([^)]+)\)\z/.match(css_string)
      unless matcher
        raise ArgumentError, "#{error_message}: #{css_string.inspect}"
      end

      color_space, args_string = matcher[1..2]
      args = args_string.strip.split(/\s*,\s*/)
      has_alpha = color_space.end_with?("a") # rgba/hsla
      if has_alpha && args.length != 4
        raise ArgumentError, "Expecting 4 fields for #{color_space}(): #{css_string.inspect}"
      elsif !has_alpha && args.length != 3
        raise ArgumentError, "Expecting 3 fields for #{color_space}(): #{css_string.inspect}"
      end

      case color_space
      when "rgb", "rgba"
        rgb, alpha = args[0, 3], args[3]
        num_percent_vals = rgb.count {|v| v.end_with?("%") }
        # CSS3 allows RGB values to be specified with all 3 as a percentage "##%"
        # or all as integer values without '%' sign.
        if num_percent_vals.zero?
          # interpret as integer values in range of 0..255
          r, g, b = rgb.map {|strval| strval.to_i.clamp(0, 255) }
          # Note, RGBA.new expects all values to be integers or floats.
          # For this case, we also turn the alpha-value into an int range 0..255
          # to match the r,g,b values.
          a = has_alpha && (alpha.to_r.clamp(0r, 1r) * 255).to_i
        elsif num_percent_vals == 3
          r, g, b = rgb.map {|strval| (strval.to_r / 100).clamp(0r, 1r) }
          a = has_alpha && alpha.to_r.clamp(0r, 1r)
        else
          raise ArgumentError, "Invalid mix of percent and integer values: #{css_string.inspect}"
        end
        return has_alpha ? RGBA.new(r, g, b, a) : RGB.new(r, g, b)
      when "hsl", "hsla"
        hue, sat, light, alpha = *args
        # CSS3 Hue values are an angle, unclear if we should convert to Integer or Rational here.
        h = hue.to_r
        s, l = [sat, light].map {|strval| (strval.to_r / 100).clamp(0r, 1r) }
        if has_alpha
          a = alpha.to_r.clamp(0r, 1r)
          return HSLA.new(h, s, l, a)
        else
          return HSL.new(h, s, l)
        end
      else
        raise ArgumentError, "Unknown color space: #{css_string.inspect}"
      end
    end
  end
end
