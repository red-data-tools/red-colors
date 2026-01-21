module Colors
  module ColorData
    # The default value of matplotlib's rcParams['axes.prop_cycle'].by_key().get('color')
    DEFAULT_COLOR_CYCLE = [ -'#1f77b4', -'#ff7f0e', -'#2ca02c', -'#d62728', -'#9467bd',
                            -'#8c564b', -'#e377c2', -'#7f7f7f', -'#bcbd22', -'#17becf' ].freeze

    # Matplotlib's base colors
    BASE_COLORS = {
      "b" => [0r,    0r,    1r].freeze,
      "g" => [0r,    0.5r,  0r].freeze,
      "r" => [1r,    0r,    0r].freeze,
      "c" => [0r,    0.75r, 0.75r].freeze,
      "m" => [0.75r, 0,     0.75r].freeze,
      "y" => [0.75r, 0.75r, 0r].freeze,
      "k" => [0r,    0r,    0r].freeze,
      "w" => [1r,    1r,    1r].freeze
    }.freeze
  end
end
