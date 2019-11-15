class ColorsXYZTest < Test::Unit::TestCase
  sub_test_case("#luv_components") do
    test("on ITU-R BT.709 D65 white point") do
      l, u, v = Colors::RGB.new(0r, 0r, 0r).to_xyz.luv_components(Colors::WHITE_POINT_D65)
      assert_in_delta(0, l)
      assert_in_delta(0, u)
      assert_in_delta(0, v)
    end
  end
end
