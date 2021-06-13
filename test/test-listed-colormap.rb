class ColorsListedColormapTest < Test::Unit::TestCase
  include TestHelper

  sub_test_case("#[]") do
    def setup
      @cm = Colors::ListedColormap.new([:red, :green, :blue])
      @cm.under_color = :black
      @cm.over_color = :white
    end

    sub_test_case("with an integer") do
      def test_aref
        assert_equal([
                       Colors::RGBA.new(1r, 0r, 0r, 1r),
                       Colors::RGBA.new(0r, 128/255r, 0r, 1r),
                       Colors::RGBA.new(0r, 0r, 1r, 1r),
                       Colors::RGBA.new(1r, 1r, 1r, 1r),
                       Colors::RGBA.new(0r, 0r, 0r, 1r),
                     ],
                     [
                       @cm[0],
                       @cm[1],
                       @cm[2],
                       @cm[3],
                       @cm[-1],
                     ])
      end
    end

    sub_test_case("with an array of integers") do
      def test_aref
        indices = [0, 1, 2, 3, -1]
        assert_equal(indices.map {|i| @cm[i] },
                     @cm[indices])
      end
    end

    sub_test_case("with a float") do
      def test_aref
        assert_equal([
                       Colors::RGBA.new(1r, 0r, 0r, 1r),
                       Colors::RGBA.new(0r, 128/255r, 0r, 1r),
                       Colors::RGBA.new(0r, 0r, 1r, 1r),
                       Colors::RGBA.new(1r, 1r, 1r, 1r),
                       Colors::RGBA.new(0r, 0r, 0r, 1r),
                     ],
                     [
                       @cm[0.1],
                       @cm[0.5],
                       @cm[0.8],
                       @cm[1.1],
                       @cm[-0.1]
                     ])
      end
    end

    sub_test_case("with an array of floats") do
      def test_aref
        indices = [0.1, 0.5, 0.8, 1.1, -0.1]
        assert_equal(indices.map {|i| @cm[i] },
                     @cm[indices])
      end
    end
  end

  def test_over_color
    cm = Colors::ListedColormap.new([:blue, :red])

    before = cm[[0, 1, 2]]
    cm.over_color = :black
    after = cm[[0, 1, 2]]

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
    cm = Colors::ListedColormap.new([:blue, :red])

    before = cm[[0, 1, -1]]
    cm.under_color = :black
    after = cm[[0, 1, -1]]

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

  def test_reversed
    cm = Colors::ListedColormap.new([:red, :green, :blue], name: "three")
    cm.under_color = :orange
    cm.over_color = :yellow
    rev = cm.reversed
    assert_equal([
                   "three_r",
                   cm[[0, 1, 2]],
                   Colors[:orange],
                   Colors[:yellow]
                 ],
                 [
                   rev.name,
                   rev[[2, 1, 0]],
                   rev.under_color,
                   rev.over_color
                 ])
  end
end
