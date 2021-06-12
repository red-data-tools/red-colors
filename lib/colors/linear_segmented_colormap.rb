module Colors
  class LinearSegmentedColormap < Colormap
    def initialize(name, segmented_data, n_colors: 256, gamma: 1.0)
      super(name, n_colors)

      @monochrome = false
      @segmented_data = segmented_data
      @gamma = gamma
    end

    attr_reader :segmented_data, :gamma

    def self.new_from_list(name, colors, n_colors: 256, gamma: 1.0)
      case colors
      when Enumerable
        colors = colors.to_a
      else
        ary = Array.try_convert(colors)
        if ary.nil?
          raise ArgumentError, "colors must be convertible to an array"
        else
          colors = ary
        end
      end

      case colors[0]
      when Array
        unless colors.all? {|a| a.length == 2 }
          raise ArgumentError, "colors array has invalid items" 
        end
        vals, colors = colors.transpose
      else
        vals = Utils.linspace(0r, 1r, colors.length)
      end

      r, g, b, a = colors.map { |c|
        Utils.make_color(c).to_rgba.components
      }.transpose

      segmented_data = {
        red:   [vals, r, r].transpose,
        green: [vals, g, g].transpose,
        blue:  [vals, b, b].transpose,
        alpha: [vals, a, a].transpose
      }

      new(name, segmented_data, n_colors: n_colors, gamma: gamma)
    end

    def gamma=(val)
      @gamma = val
      @initialized = false
    end

    private def init_colormap
      red = create_lookup_table(self.n_colors, @segmented_data[:red], @gamma)
      green = create_lookup_table(self.n_colors, @segmented_data[:green], @gamma)
      blue = create_lookup_table(self.n_colors, @segmented_data[:blue], @gamma)
      alpha = if @segmented_data.key?(:alpha)
                create_lookup_table(self.n_colors, @segmented_data[:alpha], @gamma)
              end
      @lookup_table = Array.new(self.n_colors) do |i|
        Colors::RGBA.new(red[i], green[i], blue[i], alpha ? alpha[i] : 1r)
      end
      @initialized = true
      update_extreme_colors
    end

    private def create_lookup_table(n, data, gamma=1.0)
      if data.respond_to?(:call)
        xind = Utils.linspace(0r, 1r, n).map {|x| x ** gamma }
        lut = xind.map {|i| data.(i).clamp(0, 1).to_f }
        return lut
      end

      ary = Array.try_convert(data)
      if ary.nil?
        raise ArgumentError, "data must be convertible to an array"
      elsif ary.any? {|sub| sub.length != 3 }
        raise ArgumentError, "data array must consist of 3-length arrays"
      end

      shape = [ary.length, 3]

      x, y0, y1 = ary.transpose

      if x[0] != 0.0 || x[-1] != 1.0
        raise ArgumentError,
              "data mapping points must start with x=0 and end with x=1"
      end

      unless x.each_cons(2).all? {|a, b| a < b }
        raise ArgumentError,
              "data mapping points must have x in increasing order"
      end

      if n == 1
        # Use the `y = f(x=1)` value for a 1-element lookup table
        lut = [y0[-1]]
      else
        x.map! {|v| v.to_f * (n - 1) }
        xind = Utils.linspace(0r, 1r, n).map {|i| (n - 1) * i ** gamma }
        ind = (0 ... n).map {|i| x.find_index {|v| xind[i] < v } }[1 ... -1]

        distance = ind.map.with_index do |i, j|
          (xind[j+1] - x[i - 1]) / (x[i] - x[i - 1])
        end

        lut = [
          y1[0],
          *ind.map.with_index {|i, j| distance[j] * (y0[i] - y1[i - 1]) + y1[i - 1] },
          y0[-1]
        ]
      end

      return lut.map {|v| v.clamp(0, 1).to_f }
    end
  end
end
