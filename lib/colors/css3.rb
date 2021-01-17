module Colors

  module CSSUtil

    # For RGB, CSS clamps negative values to zero and anything over 255 to 255
    def self.clamp_int(strval)
      value = strval.to_i
      return 0 if value < 0
      return 255 if value > 255
      value
    end
    
    # Rationalize a percentage string, e.g.:  "1.2%"
    # takes advantage of #to_r ignoring the '%' character.
    def self.clamp_percent(strval)
      value = strval.to_r / 100
      return 0r if value < 0r
      return 1r if value > 1r
      value
    end
    
    def self.clamp_alpha(strval)
      value = strval.to_r
      return 0r if value < 0r
      return 1r if value > 1r
      value
    end
    
  end
  
  class CSS3

    CSS_INT = '[-+]?\d+'
    CSS_PCT = '[-+]?\d+%'
    CSS_AFLT = %r/[-+]?\d*[.]?\d+/

    RGB_MATCH = %r/\Argb\((.*)\)\z/
    RGBA_MATCH = %r/\Argba\((.*)\)\z/
    HSL_PREMATCH = %r/\Ahsl\((.*)\)\z/
    HSLA_PREMATCH = %r/\Ahsla\((.*)\)\z/
    HSL_MATCH  = %r/\Ahsl\( \s* (?<hue>#{CSS_INT}) \s* , \s* (?<saturation>#{CSS_PCT}) \s* , \s* (?<lightness>#{CSS_PCT}) \s* \)\z/x
    HSLA_MATCH = %r/\Ahsla\( \s* (?<hue>#{CSS_INT}) \s* , \s* (?<saturation>#{CSS_PCT}) \s* , \s* (?<lightness>#{CSS_PCT}) \s* , \s* (?<alpha>#{CSS_AFLT}) \s* \)\z/x

    
    # Factory method for generating RGB/RGBA/HSL/HSLA Objects.
    # Parsing based on spec https://www.w3.org/TR/css-color-3 ; section 4.2
                                    
    def self.parse(css_string)
      error_message = "must be a string of `rgb(rr,gg,bb)`, `rgba(rr,gg,bb,aa)`, `hsl(hh,ss,ll)`, or `hsla(hh,ss,ll,aa)` form"
      unless css_string.respond_to?(:to_str)
        raise ArgumentError, "#{error_message}: #{css_string.inspect}"
      end

      css_string = css_string.to_str.strip

      case css_string
      when RGB_MATCH
        rgb = RGB_MATCH.match(css_string)[1].strip.split(/\s*,\s*/)
        raise ArgumentError, "Expecting 3 fields for rgb(): #{css_string.inspect}" if rgb.length != 3
        num_percent_vals = rgb.count { |v| v[-1] == '%' }
        r, g, b = if num_percent_vals == 0
                    rgb.map { |c| CSSUtil.clamp_int(c) }
                  elsif num_percent_vals == 3
                    rgb.map { |c| CSSUtil.clamp_percent(c) }
                  else
                    raise ArgumentError, "Invalid mix of percent and integer values:  #{css_string.inspect}"
                  end
        return RGB.new(r, g, b)
      when RGBA_MATCH
        rgba = RGBA_MATCH.match(css_string)[1].strip.split(/\s*,\s*/)
        raise ArgumentError, "Expecting 4 fields for rgba(): #{css_string.inspect}" if rgba.length != 4
        rgb = rgba[0..2]
        num_percent_vals = rgb.count { |v| v[-1] == '%' }
        if num_percent_vals == 0
          r, g, b = rgb.map { |c| CSSUtil.clamp_int(c) }
          # note, RGBA.new expects all values to be integers or floats.
          # for this case, we turn the alpha-value into an int range 0..255 to match the r,g,b values.
          a = (CSSUtil.clamp_alpha(rgba[3]) * 255).to_i
        elsif num_percent_vals == 3
          r, g, b = rgb.map { |c| CSSUtil.clamp_percent(c) }
          a = CSSUtil.clamp_alpha(rgba[3])
        else
          raise ArgumentError, "Invalid mix of percent and integer values:  #{css_string.inspect}"
        end
        return RGBA.new(r, g, b, a)
      when HSL_PREMATCH
        matcher = HSL_MATCH.match(css_string)
        raise ArgumentError, "Bad hsl(): #{css_string.inspect}" unless matcher
        # CSS Hue values are an angle, unclear if we should convert to int or float
        h = matcher[:hue].to_i
        s, l = %i[saturation lightness].map { |c| CSSUtil.clamp_percent(matcher[c]) }
        return HSL.new(h, s, l)
      when HSLA_PREMATCH
        matcher = HSLA_MATCH.match(css_string)
        raise ArgumentError, "Bad hsla(): #{css_string.inspect}" unless matcher
        h = matcher[:hue].to_i
        s, l = %i[saturation lightness].map { |c| CSSUtil.clamp_percent(matcher[c]) }
        a = CSSUtil.clamp_alpha(matcher[:alpha])
        return HSLA.new(h, s, l, a)
      else
        raise ArgumentError, "#{error_message}: #{css_string.inspect}"
      end
    end
  end
end  
