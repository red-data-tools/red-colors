module Colors
  module Utils
    module_function def linspace(x0, x1, n)
      Array.new(n) { |i|
        x0 + i*(x1 - x0)/(n-1.0)
      }
    end

    module_function def make_color(value)
      case value
      when Colors::AbstractColor
        value
      else
        Colors[value]
      end
    end
  end
end
