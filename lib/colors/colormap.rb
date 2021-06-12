module Colors
  class Colormap
    def initialize(name, n_colors)
      @name = name
      @n_colors = n_colors.to_int
      @bad_color = RGBA.new(0r, 0r, 0r, 0r)
      @under_color = nil
      @over_color = nil
      @under_index = self.n_colors
      @over_index = self.n_colors + 1
      @bad_index = self.n_colors + 2
      @initialized = false
    end

    attr_reader :name, :n_colors

    def [](x)
      init_colormap unless @initialized

      xs = Array(x)
      scalar_p = (xs.length == 1) && xs[0] == x

      if all_float?(xs)
        xs.map! do |v|
          v *= self.n_colors
          v = -1 if v < 0
          v = self.n_colors - 1 if v == self.n_colors
          v.clamp(-1, self.n_colors).to_i
        end
      end
      ys = xs.map do |v|
        v = case
            when v >= self.n_colors
              @over_index
            when v < 0
              @under_index
            else
              v
            end
        @lookup_table[v]
      end

      if scalar_p
        ys[0]
      else
        ys
      end
    end

    def over_color
      init_colormap unless @initialized
      @lookup_table[@over_index]
    end

    def over_color=(color)
      @over_color = color
      update_extreme_colors if @initialized
    end

    def under_color
      init_colormap unless @initialized
      @lookup_table[@under_index]
    end

    def under_color=(color)
      @under_color = color
      update_extreme_colors if @initialized
    end

    private def init_colormap
      raise NotImplementedError
    end

    private def all_float?(ary)
      ary.all? {|x| x.is_a?(Float) }
    end

    private def update_extreme_colors
      @lookup_table[@under_index] = Utils.make_color(@under_color || @lookup_table[0]).to_rgba
      @lookup_table[@over_index] = Utils.make_color(@over_color || @lookup_table[self.n_colors - 1]).to_rgba
      @lookup_table[@bad_index] = Utils.make_color(@bad_color).to_rgba
    end
  end
end
