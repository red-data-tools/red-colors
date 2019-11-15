class ColorsHUSLTest < Test::Unit::TestCase
  include TestHelper

  sub_test_case(".new") do
    test("with integer values") do
      c = Colors::HUSL.new(1, 128, 255)
      assert_equal(1r, c.hue)
      assert_equal(128/255r, c.saturation)
      assert_equal(255/255r, c.lightness)

      c = Colors::HUSL.new(-1, 128, 255)
      assert_equal(359r, c.hue)

      c = Colors::HUSL.new(361, 128, 255)
      assert_equal(1r, c.hue)

      assert_raise(ArgumentError) do
        Colors::HUSL.new(0, 0x100, 0)
      end

      assert_raise(ArgumentError) do
        Colors::HUSL.new(0, 0, 0x100)
      end

      assert_raise(ArgumentError) do
        Colors::HUSL.new(0, -1, 0)
      end

      assert_raise(ArgumentError) do
        Colors::HUSL.new(0, 0, -1)
      end
    end

    test("with float values") do
      c = Colors::HUSL.new(0.0.next_float, 0.55, 1)
      assert_equal(0.0.next_float.to_r, c.hue)
      assert_equal(0.55.to_r, c.saturation)
      assert_equal(1.0.to_r, c.lightness)

      c = Colors::HUSL.new(-0.1, 0.55, 1)
      assert_equal(360 - 0.1, c.hue)

      c = Colors::HUSL.new(360.1, 0.55, 1)
      assert_equal(Rational(360.1) - 360, c.hue)

      assert_raise(ArgumentError) do
        Colors::HUSL.new(0.0, 1.0.next_float, 0.0)
      end

      assert_raise(ArgumentError) do
        Colors::HUSL.new(0.0, 0.0, 1.0.next_float)
      end

      assert_raise(ArgumentError) do
        Colors::HUSL.new(0, -0.1, 0)
      end

      assert_raise(ArgumentError) do
        Colors::HUSL.new(0, 0, -0.1)
      end
    end

    test("with rational values") do
      c = Colors::HUSL.new(1r, 500/1000r, 1)
      assert_equal(1r, c.hue)
      assert_equal(500/1000r, c.saturation)
      assert_equal(1r, c.lightness)

      c = Colors::HUSL.new(-1r, 500/1000r, 1)
      assert_equal(359r, c.hue)

      c = Colors::HUSL.new(361r, 500/1000r, 1)
      assert_equal(1r, c.hue)

      assert_raise(ArgumentError) do
        Colors::HUSL.new(0r, 1001/1000r, 0r)
      end

      assert_raise(ArgumentError) do
        Colors::HUSL.new(0r, 0r, 1001/1000r)
      end

      assert_raise(ArgumentError) do
        Colors::HUSL.new(0r, -1/1000r, 0r)
      end

      assert_raise(ArgumentError) do
        Colors::HUSL.new(0r, 0r, -1/1000r)
      end
    end
  end

  test("#hue=") do
    c = Colors::HUSL.new(0, 0, 0)
    c.hue = 1r
    assert_equal(1r, c.hue)
    c.hue = 1.0r
    assert_equal(1r, c.hue)
    c.hue = 1
    assert_equal(1r, c.hue)
    c.hue = -1
    assert_equal(359r, c.hue)
    c.hue = 360
    assert_equal(0r, c.hue)
    c.hue = 361
    assert_equal(1r, c.hue)
  end

  test("#saturation=") do
    c = Colors::HUSL.new(0, 0, 0)
    c.saturation = 1r
    assert_equal(1r, c.saturation)
    c.saturation = 1.0r
    assert_equal(1r, c.saturation)
    c.saturation = 1
    assert_equal(1/255r, c.saturation)
    assert_raise(ArgumentError) do
      c.saturation = 1001/1000r
    end
    assert_raise(ArgumentError) do
      c.saturation = -1/1000r
    end
    assert_raise(ArgumentError) do
      c.saturation = -0.1
    end
    assert_raise(ArgumentError) do
      c.saturation = 1.0.next_float
    end
    assert_raise(ArgumentError) do
      c.saturation = 256
    end
    assert_raise(ArgumentError) do
      c.saturation = -1
    end
  end

  test("#lightness=") do
    c = Colors::HUSL.new(0, 0, 0)
    c.lightness = 1r
    assert_equal(1r, c.lightness)
    c.lightness = 1.0r
    assert_equal(1r, c.lightness)
    c.lightness = 1
    assert_equal(1/255r, c.lightness)
    assert_raise(ArgumentError) do
      c.lightness = 1001/1000r
    end
    assert_raise(ArgumentError) do
      c.lightness = -1/1000r
    end
    assert_raise(ArgumentError) do
      c.lightness = -0.1
    end
    assert_raise(ArgumentError) do
      c.lightness = 1.0.next_float
    end
    assert_raise(ArgumentError) do
      c.lightness = 256
    end
    assert_raise(ArgumentError) do
      c.lightness = -1
    end
  end

  test("==") do
    assert { Colors::HUSL.new(0, 0, 0) == Colors::HUSL.new(0, 0, 0) }
    #assert { Colors::HUSL.new(0, 0, 0) == Colors::HUSLA.new(0, 0, 0, 1r) }
  end

  test("!=") do
    assert { Colors::HUSL.new(0, 0, 0) != Colors::HUSL.new(1, 0, 0) }
    assert { Colors::HUSL.new(0, 0, 0) != Colors::HUSL.new(0, 1, 0) }
    assert { Colors::HUSL.new(0, 0, 0) != Colors::HUSL.new(0, 0, 1) }
    #assert { Colors::HUSL.new(0, 0, 0) != Colors::HUSLA.new(0, 0, 0, 0) }
  end

  test("#desaturate") do
    c = Colors::RGB.new(1r, 1r, 0r).to_husl.desaturate(0.8)
    assert_instance_of(Colors::HUSL, c)
    assert_near(Colors::HUSL.new(85.87432021817473r, 0.9838589961976354r, 0.8850923805142681r), c)
  end

  test("#to_husl") do
    black = Colors::HUSL.new(0, 0, 0)
    assert_same(black, black.to_hsl)
  end

  test("#to_rgb") do
    # black
    assert_equal(Colors::RGB.new(0, 0, 0),
                 Colors::HUSL.new(0, 0, 0).to_rgb)
    # red
    assert_near(Colors::RGB.new(1r, 0, 0),
                Colors::HUSL.new(12.177050630061776r, 1r, 0.5323711559542933r).to_rgb)
    # yellow
    assert_near(Colors::RGB.new(1r, 1r, 0),
                Colors::HUSL.new(85.87432021817473r, 1r, 0.9713855934179674r).to_rgb)
    # green
    assert_near(Colors::RGB.new(0r, 1r, 0),
                Colors::HUSL.new(127.71501294924047r, 1r, 0.8773551910965973r).to_rgb)
    # cyan
    assert_near(Colors::RGB.new(0r, 1r, 1r),
                Colors::HUSL.new(192.17705063006116r, 1r, 0.9111475231670507r).to_rgb)
    # blue
    assert_near(Colors::RGB.new(0r, 0r, 1r),
                Colors::HUSL.new(265.8743202181779r, 1r, 0.3230087290398002r).to_rgb)
    # magenta
    assert_near(Colors::RGB.new(1r, 0r, 1r),
                Colors::HUSL.new(307.7150129492436r, 1r, 0.60322731354551294r).to_rgb)
    # white
    assert_near(Colors::RGB.new(1r, 1r, 1r),
                Colors::HUSL.new(0r, 1r, 1r).to_rgb)
  end
end
