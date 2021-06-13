module Colors
  class ListedColormap < Colormap
    def initialize(colors, name: :from_list, n_colors: nil)
      @monochrome = false
      if n_colors.nil?
        @colors = Array.try_convert(colors)
        n_colors = @colors.length
      else
        case colors
        when String, Symbol
          @colors = Array.new(n_colors) { colors }
          @monochrome = true
        when Enumerable
          @colors = colors.cycle.take(n_colors)
          @monochrome = @colors.all? {|x| x == @colors[0] }
        else
          begin
            gray = Float(colors)
          rescue TypeError, ArgumentError
            raise ArgumentError,
                  "invalid value for `colors` (%p)" % colors
          else
            @colors = Array.new(n_colors) { gray }
          end
          @monochrome = true
        end
      end
      @colors.freeze

      super(name, n_colors)
    end

    attr_reader :colors

    private def init_colormap
      @lookup_table = self.colors.map {|color| Utils.make_color(color).to_rgba }
      @initialized = true
      update_extreme_colors
    end

    private def make_reverse_colormap(name)
      ListedColormap.new(self.colors.reverse, name: name, n_colors: self.n_colors)
    end
  end
end
