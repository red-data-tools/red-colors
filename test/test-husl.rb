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
    assert_near(Colors::HUSL.new(85.87432021817473r, 0.9838589961976354r, 0.8850923805142681r), c, 0.01)
  end

  test("#to_husl") do
    black = Colors::HUSL.new(0, 0, 0)
    assert_same(black, black.to_hsl)
  end

  sub_test_case("basic colors") do
    colors = [
      { rgb: "#ff0000", husl: [ 12.16, 1.0, 0.532], name: "red" },
      { rgb: "#ffff00", husl: [ 85.90, 1.0, 0.971], name: "yellow" },
      { rgb: "#00ff00", husl: [127.72, 1.0, 0.877], name: "green" },
      { rgb: "#00ffff", husl: [192.20, 1.0, 0.911], name: "cyan" },
      { rgb: "#0000ff", husl: [265.87, 1.0, 0.323], name: "blue" },
      { rgb: "#ff00ff", husl: [307.71, 1.0, 0.603], name: "magenta" },
    ]
    data(colors.map {|r| [r[:name], r] }.to_h)
    def test_husl_to_rgb(data)
      husl, rgb = data.values_at(:husl, :rgb)
      assert_equal(rgb,
                   Colors::HUSL.new(*husl).to_rgb.to_hex_string)
    end
  end

  sub_test_case("reproducing color conversion in seaborn") do
    s = 0.9 * 99/100r
    l = 0.65 * 99/100r
    palette = [
      { rgb: "#f77189", husl: [  3.590,            s, l] },
      { rgb: "#e68332", husl: [ 33.50666666666666, s, l] },
      { rgb: "#bb9832", husl: [ 63.42333333333333, s, l] },
      { rgb: "#97a431", husl: [ 93.3400,           s, l] },
      { rgb: "#50b131", husl: [123.25666666666666, s, l] },
      { rgb: "#34af84", husl: [153.17333333333332, s, l] },
      { rgb: "#36ada4", husl: [183.0900,           s, l] },
      { rgb: "#38aabf", husl: [213.00666666666663, s, l] },
      { rgb: "#3ba3ec", husl: [242.92333333333332, s, l] },
      { rgb: "#a48cf4", husl: [272.8400,           s, l] },
      { rgb: "#e867f4", husl: [302.75666666666666, s, l] }, # TODO: #e866f4 is the best
      { rgb: "#f668c2", husl: [332.67333333333335, s, l] }
    ]
    data(palette.map {|r|
      name = r[:name] || "husl(#{r[:husl]}) => #{r[:rgb]}"
      [name, r]
    }.to_h)
    def test_husl_to_rgb(data)
      husl_components, hex_string = data.values_at(:husl, :rgb)
      husl = Colors::HUSL.new(*husl_components)
      assert_equal(hex_string,
                   husl.to_rgb.to_hex_string)
    end
  end
end
