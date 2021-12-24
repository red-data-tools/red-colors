class ColorsCSSParserTest < Test::Unit::TestCase
  include TestHelper

  sub_test_case("rgb") do

    test("simple in-range integer values") do
      ref = Colors::RGB.new(1, 0, 255)
      css = Colors::CSS.parse("rgb(1,0,255)")
      assert_near(ref, css)
    end

    test("clamps out-of-range integer values") do
      ref = Colors::RGB.new(255, 0, 0)
      css = Colors::CSS.parse("rgb(   300 ,0,0)")
      assert_near(ref, css)
      css = Colors::CSS.parse("rgb(   255 , -10,0)")
      assert_near(ref, css)
    end
    
    test("in-range percent values") do
      ref = Colors::RGB.new(0, 0.55, 1)
      css = Colors::CSS.parse("rgb(0%,55%,100%)")
      assert_near(ref, css)
    end
    
    test("clamps out-of-range percent values") do
      ref = Colors::RGB.new(0r, 0r, 1r)
      css = Colors::CSS.parse("rgb(0%,0%,110%)")
      assert_near(ref, css)
      css = Colors::CSS.parse("rgb(-10%,0%,100%)")
      assert_near(ref, css)
    end

    test("bad input") do
      assert_raises ArgumentError, "mixed pct/int" do
        Colors::CSS.parse("rgb(50%,0 ,0)")
      end
      assert_raises ArgumentError, "too few args" do
        Colors::CSS.parse("rgb(50%,0%)")
      end
      assert_raises ArgumentError, "too many args" do
        Colors::CSS.parse("rgb(50%,0%,6%,0)")
      end
      assert_raises ArgumentError, "missing comma" do
        Colors::CSS.parse("rgb(50% 0% 6%)")
      end
    end

  end

  sub_test_case("rgba") do
    
    test("integer values, int alpha") do
      ref = Colors::RGBA.new(1r, 0r, 1r, 1r)
      css = Colors::CSS.parse("rgba(255,0,255,1)")
      assert_near(ref, css)
      ref = Colors::RGBA.new(1r, 0r, 1r, 0r)
      css = Colors::CSS.parse("rgba(255,0,255,0)")
      assert_near(ref, css)
    end

    test("integer values, float alpha") do
      ref = Colors::RGBA.new(255, 0, 255, 127)
      css = Colors::CSS.parse("rgba(255,0,255 ,   0.5)")
      assert_near(ref, css)
    end

    test("clamp out of range alpha values") do
      ref = Colors::RGBA.new(1r, 0, 1r, 1r)
      css = Colors::CSS.parse("rgba(255,0,255,2.0)")
      assert_near(ref, css)
      ref = Colors::RGBA.new(1r, 127/255r, 123/255r, 0.0)
      css = Colors::CSS.parse("rgba(255, 127, 123,-0.1)")
      assert_near(ref, css)
    end

    test("percent values, int alpha") do
      ref = Colors::RGBA.new(1r, 0r, 0.25r, 1r)
      css = Colors::CSS.parse("rgba(100%,0%,25%,1)")
      assert_near(ref, css)
      ref = Colors::RGBA.new(1r, 0.33r, 0.02r, 0r)
      css = Colors::CSS.parse("rgba(100% , 33%,2%,0)")
      assert_near(ref, css)
    end

    test("percent values, float alpha") do
      ref = Colors::RGBA.new(0.5r, 0, 0.06, 1/2r)
      css = Colors::CSS.parse("rgba(50%,0%,6% ,0.5)")
      assert_near(ref, css)
    end
    
    test("bad input") do
      assert_raises ArgumentError, "mixed pct/int" do
        Colors::CSS.parse("rgba(50%,0,6 ,0.5)")
      end
      assert_raises ArgumentError, "too few args" do
        Colors::CSS.parse("rgba(50%,0%,6%)")
      end
      assert_raises ArgumentError, "too many args" do
        Colors::CSS.parse("rgba(50%,0%,6%,0.5, 0.5)")
      end
      assert_raises ArgumentError, "missing comma" do
        Colors::CSS.parse("rgba(50%,0%,6% 0.5)")
      end
    end

  end

  sub_test_case("hsl") do
    
    test("in-range hsl") do
      ref = Colors::HSL.new(180, 0, 0.5)
      css = Colors::CSS.parse("hsl( 180, 0% , 50% )")
      assert_near(ref, css)
    end

    test("clamps out-of-range integer values") do
      ref = Colors::HSL.new(180, 0, 0.5)
      css = Colors::CSS.parse("hsl(-180,0%,50%)")
      assert_near(ref, css)
      css = Colors::CSS.parse("hsl(180,-10%,50%)")
      assert_near(ref, css)
      css = Colors::CSS.parse("hsl(540,-10%,50%)")
      assert_near(ref, css)
      ref = Colors::HSL.new(0, 1.0, 1.0)
      css = Colors::CSS.parse("hsl(0,100%,100%)")
      assert_near(ref, css)
      css = Colors::CSS.parse("hsl(360,100%,100%)")
      assert_near(ref, css)
    end
    
    test("bad input") do
      assert_raises ArgumentError, "too many args" do
        css = Colors::CSS.parse("hsl( 180, 0% , 50%, 50% )")
      end
      assert_raises ArgumentError, "too few args" do
        css = Colors::CSS.parse("hsl( 180, 0%)")
      end
      assert_raises ArgumentError, "missing comma" do
        css = Colors::CSS.parse("hsl( 180, 0% 50% )")
      end
    end
  end

  
  sub_test_case("hsla") do
    
    test("in-range hsla") do
      ref = Colors::HSLA.new(180, 0, 0.5, 1.0)
      css = Colors::CSS.parse("hsla( 180, 0% , 50%,1.0)")
      assert_near(ref, css)
    end

    test("clamps out-of-range integer values") do
      ref = Colors::HSLA.new(180, 0, 0.5, 0.1)
      css = Colors::CSS.parse("hsla(-180,0%,50%,0.1)")
      assert_near(ref, css)
      css = Colors::CSS.parse("hsla(180,-10%,50%, 0.1)")
      assert_near(ref, css)
      css = Colors::CSS.parse("hsla(540,-10%,50%, 0.1)")
      assert_near(ref, css)
      ref = Colors::HSLA.new(0, 1.0, 1.0, 0.0)
      css = Colors::CSS.parse("hsla(0,100%,100%,0.0)")
      assert_near(ref, css)
      css = Colors::CSS.parse("hsla(360,100%,100%, 0.0)")
      assert_near(ref, css)
    end
    
    test("bad input") do
      assert_raises ArgumentError, "too many args" do
        css = Colors::CSS.parse("hsla( 180, 0% , 50%, 0.0, 0.0 )")
      end
      assert_raises ArgumentError, "too few args" do
        css = Colors::CSS.parse("hsla( 180, 0%, 0.0)")
      end
      assert_raises ArgumentError, "missing comma" do
        css = Colors::CSS.parse("hsla( 180, 0% 50% 0.0 )")
      end
    end
    
  end
  
end
