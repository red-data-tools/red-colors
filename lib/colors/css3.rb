module Colors

  module CSSUtil

    # For RGB, CSS clamps values at min=0, max=255
    def self.clamp_int(strval)
      [[strval.to_i, 0].max, 255].min
    end
    
    # Rationalize a percentage string, e.g.:  "1.2%"
    # takes advantage of #to_r ignoring the '%' character.
    # Clamp between 0r and 1r
    def self.clamp_percent(strval)
      [[strval.to_r / 100, 0r].max, 1r].min
    end
    
    # Rationalize alpha value.
    # Clamp between 0r and 1r
    def self.clamp_alpha(strval)
      [[strval.to_r, 0r].max, 1r].min
    end
    
  end
  
  class CSS3

    # Factory method for generating RGB/RGBA/HSL/HSLA Objects.
    # Parsing based on spec https://www.w3.org/TR/css-color-3 ; section 4.2
                                    
    def self.parse(css_string)
      error_message = "must be a string of `rgb(rr,gg,bb)`, `rgba(rr,gg,bb,aa)`, `hsl(hh,ss,ll)`, or `hsla(hh,ss,ll,aa)` form"
      unless css_string.respond_to?(:to_str)
        raise ArgumentError, "#{error_message}: #{css_string.inspect}"
      end

      css_string = css_string.to_str.strip
      matcher = /\A(rgb|rgba|hsl|hsla)\((.*)\)\z/.match(css_string)
      if matcher
        css_type, argstring = matcher[1..2]
        arglist = argstring.strip.split(/\s*,\s*/)
        has_alpha = css_type[-1] == 'a' # rgba/hsla
        if has_alpha && arglist.length !=4
          raise ArgumentError, "Expecting 4 fields for #{css_type}(): #{css_string.inspect}"
        elsif !has_alpha && arglist.length !=3
          raise ArgumentError, "Expecting 3 fields for #{css_type}(): #{css_string.inspect}"
        end
          
        case css_type
        when /rgb/
          rgb, alpha =  arglist[0..2], arglist[3]
          num_percent_vals = rgb.count { |v| v[-1] == '%' }
          # CSS3 allows RGB values to be specified with all 3 as a percentage "##%"
          # or all as integer values without '%' sign.
          if num_percent_vals == 0
            r, g, b = rgb.map { |c| CSSUtil.clamp_int(c) }
            # note, RGBA.new expects all values to be integers or floats.
            # for this case, we turn the alpha-value into an int range 0..255 to match the r,g,b values.
            a = alpha ? (CSSUtil.clamp_alpha(alpha) * 255).to_i : nil
            
          elsif num_percent_vals == 3
            r, g, b = rgb.map { |c| CSSUtil.clamp_percent(c) }
            a = alpha ? CSSUtil.clamp_alpha(alpha) : nil
          else
            raise ArgumentError, "Invalid mix of percent and integer values:  #{css_string.inspect}"
          end
          return a ? RGBA.new(r, g, b, a) : RGB.new(r, g, b)
        when /hsl/
          hue, sat, light, alpha = *arglist
          # CSS3 Hue values are an angle, unclear if we should convert to Integer or Rational here.
          h = hue.to_r
          s, l = [sat, light].map { |c| CSSUtil.clamp_percent(c) }
          a = alpha ? CSSUtil.clamp_alpha(alpha) : nil
          return a ? HSLA.new(h, s, l, a) : HSL.new(h, s, l)
        else
          raise "Illegal condition"
        end
        
      else
        raise ArgumentError, "#{error_message}: #{css_string.inspect}"
      end
    end
  end
end  
