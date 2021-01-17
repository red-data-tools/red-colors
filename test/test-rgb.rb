class ColorsRGBTest < Test::Unit::TestCase
  include TestHelper

  sub_test_case(".new") do
    test("with integer values") do
      c = Colors::RGB.new(1, 128, 255)
      assert_equal(1/255r, c.red)
      assert_equal(128/255r, c.green)
      assert_equal(255/255r, c.blue)

      assert_raise(ArgumentError) do
        Colors::RGB.new(0, 0, 0x100)
      end

      assert_raise(ArgumentError) do
        Colors::RGB.new(0, 0, -1)
      end
    end

    test("with float values") do
      c = Colors::RGB.new(0.0.next_float, 0.55, 1)
      assert_equal(0.0.next_float.to_r, c.red)
      assert_equal(0.55.to_r, c.green)
      assert_equal(1.0.to_r, c.blue)

      assert_raise(ArgumentError) do
        Colors::RGB.new(0.0, 0.0, 1.0.next_float)
      end

      assert_raise(ArgumentError) do
        Colors::RGB.new(0, 0, -0.1)
      end
    end

    test("with rational values") do
      c = Colors::RGB.new(1/1000r, 500/1000r, 1)
      assert_equal(1/1000r, c.red)
      assert_equal(500/1000r, c.green)
      assert_equal(1r, c.blue)

      assert_raise(ArgumentError) do
        Colors::RGB.new(0.0, 0.0, 1001/1000r)
      end

      assert_raise(ArgumentError) do
        Colors::RGB.new(0, 0, -1/1000r)
      end
    end
  end

  test("#red=") do
    c = Colors::RGB.new(0, 0, 0)
    c.red = 1r
    assert_equal(1r, c.red)
    c.red = 1.0r
    assert_equal(1r, c.red)
    c.red = 1
    assert_equal(1/255r, c.red)
    assert_raise(ArgumentError) do
      c.red = 1001/1000r
    end
    assert_raise(ArgumentError) do
      c.red = -1/1000r
    end
    assert_raise(ArgumentError) do
      c.red = -0.1
    end
    assert_raise(ArgumentError) do
      c.red = 1.0.next_float
    end
    assert_raise(ArgumentError) do
      c.red = 256
    end
    assert_raise(ArgumentError) do
      c.red = -1
    end
  end

  test("#green=") do
    c = Colors::RGB.new(0, 0, 0)
    c.green = 1r
    assert_equal(1r, c.green)
    c.green = 1.0r
    assert_equal(1r, c.green)
    c.green = 1
    assert_equal(1/255r, c.green)
    assert_raise(ArgumentError) do
      c.green = 1001/1000r
    end
    assert_raise(ArgumentError) do
      c.green = -1/1000r
    end
    assert_raise(ArgumentError) do
      c.green = -0.1
    end
    assert_raise(ArgumentError) do
      c.green = 1.0.next_float
    end
    assert_raise(ArgumentError) do
      c.green = 256
    end
    assert_raise(ArgumentError) do
      c.green = -1
    end
  end

  test("#blue=") do
    c = Colors::RGB.new(0, 0, 0)
    c.blue = 1r
    assert_equal(1r, c.blue)
    c.blue = 1.0r
    assert_equal(1r, c.blue)
    c.blue = 1
    assert_equal(1/255r, c.blue)
    assert_raise(ArgumentError) do
      c.blue = 1001/1000r
    end
    assert_raise(ArgumentError) do
      c.blue = -1/1000r
    end
    assert_raise(ArgumentError) do
      c.blue = -0.1
    end
    assert_raise(ArgumentError) do
      c.blue = 1.0.next_float
    end
    assert_raise(ArgumentError) do
      c.blue = 256
    end
    assert_raise(ArgumentError) do
      c.blue = -1
    end
  end

  test("==") do
    assert { Colors::RGB.new(0, 0, 0) == Colors::RGB.new(0, 0, 0) }
    assert { Colors::RGB.new(0, 0, 0) == Colors::RGBA.new(0, 0, 0, 1r) }
  end

  test("!=") do
    assert { Colors::RGB.new(0, 0, 0) != Colors::RGB.new(1, 0, 0) }
    assert { Colors::RGB.new(0, 0, 0) != Colors::RGB.new(0, 1, 0) }
    assert { Colors::RGB.new(0, 0, 0) != Colors::RGB.new(0, 0, 1) }
    assert { Colors::RGB.new(0, 0, 0) != Colors::RGBA.new(0, 0, 0, 0) }
  end

  test("#desaturate") do
    c = Colors::RGB.new(1r, 1r, 1r).desaturate(0.8)
    assert_instance_of(Colors::RGB, c)
    assert_near(Colors::HSL.new(0r, 0.8r, 1r).to_rgb, c)
  end

  sub_test_case(".parse") do
    test("for #rgb") do
      assert_equal(Colors::RGB.new(0, 0, 0),
                   Colors::RGB.parse("#000"))
      assert_equal(Colors::RGB.new(0x33, 0x66, 0x99),
                   Colors::RGB.parse("#369"))
      assert_equal(Colors::RGB.new(255, 255, 255),
                   Colors::RGB.parse("#fff"))
    end

    test("for #rrggbb") do
      assert_equal(Colors::RGB.new(0, 0, 0),
                   Colors::RGB.parse("#000000"))
      assert_equal(Colors::RGB.new(1, 0, 0),
                   Colors::RGB.parse("#010000"))
      assert_equal(Colors::RGB.new(0, 1, 0),
                   Colors::RGB.parse("#000100"))
      assert_equal(Colors::RGB.new(0, 0, 1),
                   Colors::RGB.parse("#000001"))
    end


    test("error cases") do
      # `#rgba` is error
      assert_raise(ArgumentError) do
        Colors::RGB.parse("#0000")
      end

      # `#rrggbbaa` is error
      assert_raise(ArgumentError) do
        Colors::RGB.parse("#00000000")
      end

      assert_raise(ArgumentError) do
        Colors::RGB.parse("#00")
      end

      assert_raise(ArgumentError) do
        Colors::RGB.parse("#00000")
      end

      assert_raise(ArgumentError) do
        Colors::RGB.parse("#0000000")
      end

      assert_raise(ArgumentError) do
        Colors::RGB.parse(nil)
      end

      assert_raise(ArgumentError) do
        Colors::RGB.parse(1)
      end

      assert_raise(ArgumentError) do
        Colors::RGB.parse("")
      end

      assert_raise(ArgumentError) do
        Colors::RGB.parse("333")
      end

      assert_raise(ArgumentError) do
        Colors::RGB.parse("#xxx")
      end
    end
  end

  test("#to_hex_string") do
    assert_equal("#000000",
                 Colors::RGB.new(0, 0, 0).to_hex_string)
    assert_equal("#ff0000",
                 Colors::RGB.new(1r, 0, 0).to_hex_string)
    assert_equal("#00ff00",
                 Colors::RGB.new(0, 1r, 0).to_hex_string)
    assert_equal("#0000ff",
                 Colors::RGB.new(0, 0, 1r).to_hex_string)
    assert_equal("#ffffff",
                 Colors::RGB.new(1r, 1r, 1r).to_hex_string)
    assert_equal("#808080",
                 Colors::RGB.new(0.5, 0.5, 0.5).to_hex_string)
    assert_equal("#333333",
                 Colors::RGB.new(0x33, 0x33, 0x33).to_hex_string)
  end

  test("#to_rgb") do
    black = Colors::RGB.new(0, 0, 0)
    assert_same(black, black.to_rgb)
  end

  test("#to_rgba") do
    black = Colors::RGB.new(0, 0, 0)
    assert_equal(Colors::RGBA.new(0, 0, 0, 255),
                 black.to_rgba)
    assert_equal(Colors::RGBA.new(0, 0, 0, 0),
                 black.to_rgba(alpha: 0))
    assert_equal(Colors::RGBA.new(0, 0, 0, 0.5),
                 black.to_rgba(alpha: 0.5))

    assert_raise(ArgumentError) do
      black.to_rgba(alpha: nil)
    end

    assert_raise(ArgumentError) do
      black.to_rgba(alpha: 256)
    end

    assert_raise(ArgumentError) do
      black.to_rgba(alpha: -0.1)
    end

    assert_raise(ArgumentError) do
      black.to_rgba(alpha: 1.0.next_float)
    end
  end

  test("#to_hsl") do
    # black
    assert_equal(Colors::HSL.new(0r, 0r, 0r),
                 Colors::RGB.new(0r, 0r, 0r).to_hsl)
    # red
    assert_equal(Colors::HSL.new(0r, 1r, 0.5r),
                 Colors::RGB.new(1r, 0r, 0r).to_hsl)
    # yellow
    assert_equal(Colors::HSL.new(60r, 1r, 0.5r),
                 Colors::RGB.new(1r, 1r, 0r).to_hsl)
    # green
    assert_equal(Colors::HSL.new(120r, 1r, 0.5r),
                 Colors::RGB.new(0r, 1r, 0r).to_hsl)
    # cyan
    assert_equal(Colors::HSL.new(180r, 1r, 0.5r),
                 Colors::RGB.new(0r, 1r, 1r).to_hsl)
    # blue
    assert_equal(Colors::HSL.new(240r, 1r, 0.5r),
                 Colors::RGB.new(0r, 0r, 1r).to_hsl)
    # magenta
    assert_equal(Colors::HSL.new(300r, 1r, 0.5r),
                 Colors::RGB.new(1r, 0r, 1r).to_hsl)
    # white
    assert_equal(Colors::HSL.new(0r, 0r, 1r),
                 Colors::RGB.new(1r, 1r, 1r).to_hsl)
  end

  test("#to_husl") do
    # black
    assert_equal(Colors::HUSL.new(0, 0, 0),
                 Colors::RGB.new(0, 0, 0).to_husl)
    # red
    assert_near(Colors::HUSL.new(12.177050630061776r, 1r, 0.5323711559542933r),
                Colors::RGB.new(1r, 0, 0).to_husl)
    # yellow
    assert_near(Colors::HUSL.new(85.87432021817473r, 1r, 0.9713855934179674r),
                Colors::RGB.new(1r, 1r, 0).to_husl)
    # green
    assert_near(Colors::HUSL.new(127.71501294924047r, 1r, 0.8773551910965973r),
                Colors::RGB.new(0r, 1r, 0).to_husl)
    # cyan
    assert_near(Colors::HUSL.new(192.17705063006116r, 1r, 0.9111475231670507r),
                Colors::RGB.new(0r, 1r, 1r).to_husl)
    # blue
    assert_near(Colors::HUSL.new(265.8743202181779r, 1r, 0.3230087290398002r),
                Colors::RGB.new(0r, 0r, 1r).to_husl)
    # magenta
    assert_near(Colors::HUSL.new(307.7150129492436r, 1r, 0.60322731354551294r),
                Colors::RGB.new(1r, 0r, 1r).to_husl)
    # white
    assert_near(Colors::HUSL.new(0r, 0r, 1r),
                Colors::RGB.new(1r, 1r, 1r).to_husl)
  end

  data do
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
          data_set[label] = [code, Colors::RGB.new(red, green, blue)]
        end
      end
    end
    # colors 232-256 are grayscale colors
    (0...24).each do |y|
      code = 232 + y
      level = 10*y + 8
      label = "Color #{code} is gray(#{level})"
      data_set[label] = [code, Colors::RGB.new(level, level, level)]
    end
    # Some colors to check cloest color finder
    [
      [   0,   0,   8,  16 ],
      [   0,   8,   0,  16 ],
      [  11,   0,   0,  16 ],
      [   0,   0,  12, 232 ],
      [   0,  12,   0, 232 ],
      [  12,   0,   0, 232 ],

      [   0,   0,  75,  17 ],
      [   0,  75,   0,  22 ],
      [  75,   0,   0,  52 ],

      [   0, 128, 128,  30 ],
      [ 102, 102, 102, 241 ],
      [ 103, 103, 103, 242 ],
      [ 208, 238, 238, 254 ],
      [ 208, 208, 238, 189 ],

      # TODO: Reconsider the following cases
      [   0,   0,  55, 233 ],
      [   0,  55,   0, 233 ],
      [  55,   0,   0, 233 ],
      [   0,   0,  74, 234 ],
      [   0,  74,   0, 234 ],
      [  74,   0,   0, 234 ],
    ].each do |r, g, b, code|
      label = "rgb(#{r}, #{g}, #{b}) is color #{code}"
      data_set[label] = [code, Colors::RGB.new(r, g, b)]
    end
    data_set
  end
  def test_to_xterm256
    code, rgb = data
    assert_equal(Colors::Xterm256.new(code),
                 rgb.to_xterm256)
  end
end
