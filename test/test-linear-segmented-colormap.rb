class ColorsLinearSegmentedColormapTest < Test::Unit::TestCase
  include TestHelper

  sub_test_case("#[]") do
    def setup
      @cm = Colors::LinearSegmentedColormap.new_from_list(:triple_colors, [:red, :green, :blue], n_colors: 11)
      @cm.under_color = :black
      @cm.over_color = :white
    end

    sub_test_case("with an integer") do
      data do
        expected = [
          Colors::RGBA.new(1r, 0r, 0r, 1r),
          Colors::RGBA.new(0r, 128/255r, 0r, 1r),
          Colors::RGBA.new(0r, 0r, 1r, 1r),
          Colors::RGBA.new(1r, 1r, 1r, 1r),
          Colors::RGBA.new(0r, 0r, 0r, 1r),
        ]
        indices = [0, 5, 10, 11, -1]
        indices.zip(expected).map { |i, c|
          ["cmap[#{i}]", {i: i, expected_color: c}]
        }.to_h
      end
      def test_aref(data)
        i, expected = data.values_at(:i, :expected_color)
        assert_near(expected, @cm[i])
      end
    end

    sub_test_case("with an array of integers") do
      def test_aref
        indices = [0, 5, 10, 11, -1]
        assert_equal(indices.map {|i| @cm[i] },
                     @cm[indices])
      end
    end

    sub_test_case("with a float") do
      data do
        expected = [
          Colors::RGBA.new(0.6r, 0.20078431372549022r, 0.0r, 1r),
          Colors::RGBA.new(0.19999999999999996r, 0.40156862745098043r, 0.0r, 1r),
          Colors::RGBA.new(0.0r, 0.4015686274509803r, 0.20000000000000018r, 1r),
          Colors::RGBA.new(0.0r, 0.20078431372549022r, 0.6r, 1r),
          Colors::RGBA.new(1r, 1r, 1r, 1r),
          Colors::RGBA.new(0r, 0r, 0r, 1r),
        ]
        indices = [0.2, 0.4, 0.6, 0.8, 1.2, -0.2]
        indices.zip(expected).map { |i, c|
          ["cmap[#{i}]", {i: i, expected_color: c}]
        }.to_h
      end
      def test_aref(data)
        i, expected = data.values_at(:i, :expected_color)
        assert_near(expected, @cm[i])
      end
    end

    sub_test_case("with an array of floats") do
      def test_aref
        indices = [0.2, 0.4, 0.6, 0.8, 1.2, -0.2]
        assert_equal(indices.map {|i| @cm[i] },
                     @cm[indices])
      end
    end
  end

  def test_over_color
    cm = Colors::LinearSegmentedColormap.new_from_list(:blue_and_red, [:blue, :red])

    before = cm[[0, 255, 256]]
    cm.over_color = :black
    after = cm[[0, 255, 256]]

    assert_equal([
                   [
                     Colors::RGBA.new(0r, 0r, 1r, 1r),
                     Colors::RGBA.new(1r, 0r, 0r, 1r),
                     Colors::RGBA.new(1r, 0r, 0r, 1r),
                   ],
                   [
                     Colors::RGBA.new(0r, 0r, 1r, 1r),
                     Colors::RGBA.new(1r, 0r, 0r, 1r),
                     Colors::RGBA.new(0r, 0r, 0r, 1r),
                   ]
                 ],
                 [
                   before,
                   after
                 ])
  end

  def test_under_color
    cm = Colors::LinearSegmentedColormap.new_from_list(:blue_and_red, [:blue, :red])

    before = cm[[0, 255, -1]]
    cm.under_color = :black
    after = cm[[0, 255, -1]]

    assert_equal([
                   [
                     Colors::RGBA.new(0r, 0r, 1r, 1r),
                     Colors::RGBA.new(1r, 0r, 0r, 1r),
                     Colors::RGBA.new(0r, 0r, 1r, 1r),
                   ],
                   [
                     Colors::RGBA.new(0r, 0r, 1r, 1r),
                     Colors::RGBA.new(1r, 0r, 0r, 1r),
                     Colors::RGBA.new(0r, 0r, 0r, 1r),
                   ]
                 ],
                 [
                   before,
                   after
                 ])
  end
end

