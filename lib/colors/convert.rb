module Colors
  module Convert
    module_function

    # Sort alphabetically by FROM name such as degree, LCh, LUV and so on.

    # Utilities

    private def dot_product(matrix, vector)
      matrix.map do |row|
        product = 0.0
        row.zip(vector) do |value1, value2|
          product += value1 * value2
        end
        product
      end
    end

    def max_chroma(l, h)
      h_rad = degree_to_radian(h)
      sin_h = Math.sin(h_rad).to_r
      cos_h = Math.cos(h_rad).to_r

      max = Float::INFINITY
      luminance_bounds(l).each do |line|
        len = line[1] / (sin_h - line[0] * cos_h)
        max = len if 0 <= len && len < max
      end
      max
    end

    private def luminance_bounds(l)
      sub1 = (l + 16)**3 / 1560896r
      sub2 = sub1 > XYZ::EPSILON ? sub1 : l/XYZ::KAPPA

      bounds = Array.new(6) { [0r, 0r] }
      0.upto(2) do |ch|
        m1 = XYZ2RGB[ch][0].to_r
        m2 = XYZ2RGB[ch][1].to_r
        m3 = XYZ2RGB[ch][2].to_r

        [0, 1].each do |t|
          top1 = (284517r * m1 - 94839r * m3) * sub2
          top2 = (838422r * m3 + 769860r * m2 + 731718r * m1) * l * sub2 - 769860r * t * l
          bottom = (632260r * m3 - 126452r * m2) * sub2 + 126452r * t

          bounds[ch*2 + t][0] = top1 / bottom
          bounds[ch*2 + t][1] = top2 / bottom
        end
      end
      bounds
    end

    # degree -> ???

    DEG2RAD = 0.01745329251994329577r  # 2 * pi / 360
    def degree_to_radian(d)
      d * DEG2RAD
    end

    # LCh -> ???

    def lch_to_husl(l, c, h)
      if l > 99.9999999 || l < 1e-8
        s = 0r
      else
        mx = max_chroma(l, h)
        s = c / mx * 100r
      end

      h = 0r if c < 1e-8

      [h, s/100r, l/100r]
    end

    def lch_to_luv(l, c, h)
      h_rad = degree_to_radian(h)
      u = Math.cos(h_rad).to_r * c
      v = Math.sin(h_rad).to_r * c
      [l, u, v]
    end

    def lch_to_xyz(l, c, h)
      luv_to_xyz(*lch_to_luv(l, c, h))
    end

    # linear-sRGB -> ???

    def linear_srgb_to_srgb(r, g, b)
      [r, g, b].map do |v|
        # the following is an optimization technique for `1.055*v**(1/2.4) - 0.055`.
        # x^y ~= exp(y*log(x)) ~= exp2(y*log2(y)); the middle form is faster
        #
        # See https://github.com/JuliaGraphics/Colors.jl/issues/351#issuecomment-532073196
        # for more detail benchmark in Julia language.
        if v <= 0.0031308
          12.92*v
        else
          1.055 * Math.exp(1/2.4 * Math.log(v)) - 0.055
        end
      end
    end

    # Luv -> ???

    def luv_to_husl(l, u, v)
      lch_to_husl(*luv_to_lch(l, u, v))
    end

    def luv_to_lch(l, u, v)
      c = Math.sqrt(u*u + v*v).to_r

      if c < 1e-8
        h = 0r
      else
        h = Math.atan2(v, u).to_r * 180/Math::PI.to_r
        h += 360r if h < 0
      end

      [l, c, h]
    end

    def luv_to_xyz(l, u, v)
      return [0r, 0r, 0r] if l <= 1e-8

      wp_u, wp_v = WHITE_POINT_D65.uv_values
      var_u = u / (13 * l) + wp_u
      var_v = v / (13 * l) + wp_v
      y = if l < 8
            l / XYZ::KAPPA
          else
            ((l + 16r) / 116r)**3
          end
      x = -(9 * y * var_u) / ((var_u - 4) * var_v - var_u * var_v)
      z = (9 * y - (15 * var_v * y) - (var_v * x)) / (3 * var_v)
      [x, y, z]
    end

    # RGB -> ???

    RGB2XYZ = [
      [  0.41239079926595948129,  0.35758433938387796373,  0.18048078840183428751 ],
      [  0.21263900587151035754,  0.71516867876775592746,  0.07219231536073371500 ],
      [  0.01933081871559185069,  0.11919477979462598791,  0.95053215224966058086 ]
    ]

    def rgb_to_xyz(r, g, b)
      dot_product(RGB2XYZ, srgb_to_linear_srgb(r, g, b))
    end

    def rgb_to_xterm256(r, g, b)
      i = closest_xterm256_rgb_index(r)
      j = closest_xterm256_rgb_index(g)
      k = closest_xterm256_rgb_index(b)

      r0 = xterm256_rgb_index_to_rgb_value(i)
      g0 = xterm256_rgb_index_to_rgb_value(j)
      b0 = xterm256_rgb_index_to_rgb_value(k)
      d0 = (r - r0)**2 + (g - g0)**2 + (b - b0)**2

      l = closest_xterm256_gray_index(r, g, b)
      gr = xterm256_gray_index_to_gray_level(l)
      d1 = (r - gr)**2 + (g - gr)**2 + (b - gr)**2

      if d0 > d1
        xterm256_gray_index_to_code(l)
      else
        xterm256_rgb_indices_to_code(i, j, k)
      end
    end

    def xterm256_rgb_index_to_rgb_value(i)
      (i == 0) ? 0 : (40*i + 55)/255.0
    end

    def closest_xterm256_rgb_index(x)
      ([x*255 - 55, 0].max / 40.0).round
    end

    def xterm256_gray_index_to_gray_level(i)
      (10*i + 8)/255.0
    end

    def closest_xterm256_gray_index(r, g, b)
      ((255*(r + g + b) - 24)/30.0).round.clamp(0, 23)
    end

    def xterm256_rgb_indices_to_code(i, j, k)
      6*(6*i + j) + k + 16
    end

    def xterm256_gray_index_to_code(i)
      i + 232
    end

    # sRGB -> ???

    def srgb_to_linear_srgb(r, g, b)
      [r, g, b].map do |v|
        if v > 0.04045
          ((v + 0.055r) / 1.055r) ** 2.4r
        else
          v / 12.92r
        end
      end
    end

    # XYZ -> ???

    XYZ2RGB = [
      [  3.24096994190452134377, -1.53738317757009345794, -0.49861076029300328366 ],
      [ -0.96924363628087982613,  1.87596750150772066772,  0.04155505740717561247 ],
      [  0.05563007969699360846, -0.20397695888897656435,  1.05697151424287856072 ]
    ]
    def xyz_to_rgb(x, y, z)
      r, g, b = dot_product(XYZ2RGB, [x, y, z])
      r, g, b = srgb_to_linear_srgb(r, g, b)
      [
        r.clamp(0r, 1r),
        g.clamp(0r, 1r),
        b.clamp(0r, 1r)
      ]
    end
  end
end
