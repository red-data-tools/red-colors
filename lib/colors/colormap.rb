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

      if all_ratio?(xs)
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

    def reversed
      rev_name = "#{self.name}_r" unless self.name.nil?
      rev = make_reverse_colormap(rev_name)
      rev.over_color = self.over_color
      rev.under_color = self.under_color
      return rev
    end

    private def make_reverse_colormap(name)
      raise NotImplementedError
    end

    PNG_WIDTH = 512
    PNG_HEIGHT = 64

    def to_png
      require "chunky_png"
      png = ChunkyPNG::Image.new(PNG_WIDTH, PNG_HEIGHT, ChunkyPNG::Color::TRANSPARENT)
      x = Utils.linspace(0, 1, PNG_WIDTH)
      (0 ... PNG_WIDTH).each do |i|
        color = self[x[i].to_f]
        png_color = ChunkyPNG::Color.rgba(*color.components.map{|v| (v*255).to_i })
        png.line(i, 0, i, PNG_HEIGHT-1, png_color)
      end
      png.to_blob
    end

    def to_html
      require "base64"
      png_blob = to_png
      png_base64 = Base64.encode64(png_blob)
      html = %Q[<div style="vertical-align: middle;">] +
             %Q[<strong>#{self.name}</strong> ] +
             %Q[</div>] +
             %Q[<div class="cmap"><img alt="#{self.name} colormap" ] +
             %Q[title="#{self.name}" style="border: 1px solid #555;" ] +
             %Q[src="data:image/png;base64,#{png_base64}"></div>] +
             %Q[<div style="vertical-align: middle; ] +
             %Q[max-width: #{PNG_WIDTH + 2}px; ] +
             %Q[display: flex; justify-content: space-between;">] +
             %Q[<div style="float: left;">] +
             %Q[#{html_color_block(under_color)} under</div>] +
             # TODO: bad_color support
             # %Q[<div style="margin: 0 auto; display: inline-block;">] +
             # %Q[bad #{html_color_block(bad_color)}</div>] +
             %Q[<div style="float: right;">] +
             %Q[over #{html_color_block(over_color)}</div>]
      ["text/html", html]
    end

    private def html_color_block(color)
      hex_color = color.to_hex_string
      html = %Q[<div title="#{hex_color}" style="display: inline-block; ] +
             %Q[width: 1em; height: 1em; margin: 0; vertical-align: middle; ] +
             %Q[border: 1px solid #555; background-color: #{hex_color};">] +
             %Q[</div>]
      html
    end

    private def init_colormap
      raise NotImplementedError
    end

    private def all_ratio?(ary)
      ary.all? {|x| x.is_a?(Float) || x.is_a?(Rational) }
    end

    private def update_extreme_colors
      @lookup_table[@under_index] = Utils.make_color(@under_color || @lookup_table[0]).to_rgba
      @lookup_table[@over_index] = Utils.make_color(@over_color || @lookup_table[self.n_colors - 1]).to_rgba
      @lookup_table[@bad_index] = Utils.make_color(@bad_color).to_rgba
    end
  end
end
