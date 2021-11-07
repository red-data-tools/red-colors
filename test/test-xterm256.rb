class ColorsXterm256Test < Test::Unit::TestCase
  include TestHelper

  sub_test_case(".new") do
    sub_test_case("with color code") do
      test("the regular case") do
        codes = [16, 255]
        colors = codes.map {|i| Colors::Xterm256.new(i) }
        assert_equal(codes,
                     colors.map(&:code))
      end

      data do
        (0..15).map { |code|
          ["ANSI color #{code}", code]
        }.to_h
      end
      def test_ansi_color_code(code)
        assert_raise(ArgumentError) do
          Colors::Xterm256.new(code)
        end
      end

      test("the negative argument") do
        assert_raise(ArgumentError) do
          Colors::Xterm256.new(-1)
        end
      end

      test("too large argument") do
        assert_raise(ArgumentError) do
          Colors::Xterm256.new(256)
        end
      end
    end
  end

  test("==") do
    assert { Colors::Xterm256.new(16) == Colors::Xterm256.new(16) }
    assert { Colors::Xterm256.new(132) == Colors::Xterm256.new(132) }
  end

  test("!=") do
    assert { Colors::Xterm256.new(16) != Colors::Xterm256.new(17) }
  end

  RGB2GREY = [0.21263900587151035754r, 0.71516867876775592746r, 0.07219231536073371500r]

  data(keep: true) do
    data_set = {}
    # colors 16-231 are a 6x6x6 color cube
    (0...6).each do |r|
      (0...6).each do |g|
        (0...6).each do |b|
          code = 6*(6*r + g) + b + 16
          red   = (r > 0) ? 40*r + 55 : r
          green = (g > 0) ? 40*g + 55 : g
          blue  = (b > 0) ? 40*b + 55 : b
          label = "Color #{code} is rgb(#{red}, #{green}, #{blue})"
          rgb = Colors::RGB.new(red, green, blue)
          red, green, blue = Colors::Convert.srgb_to_linear_srgb(*rgb.components)
          grey = RGB2GREY[0]*red + RGB2GREY[1]*green + RGB2GREY[2]*blue
          data_set[label] = [code, rgb, grey]
        end
      end
    end
    # colors 232-256 are grayscale colors
    (0...24).each do |y|
      code = 232 + y
      level = 10*y + 8
      grey = level/255r
      label = "Color #{code} is gray(#{level})"
      data_set[label] = [code, Colors::RGB.new(level, level, level), grey]
    end
    data_set
  end

  def test_to_rgb(data)
    code, rgb, _grey = data
    assert_equal(rgb,
                 Colors::Xterm256.new(code).to_rgb)
  end

  def test_to_grey_level(data)
    code, _rgb, grey = data
    assert_in_delta(grey,
                    Colors::Xterm256.new(code).to_grey_level,
                    1e-12)
  end
end
