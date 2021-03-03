require_relative "lib/colors"


g240 = Colors::Xterm256.new(240)
c19 = Colors::Xterm256.new(19)
c100 = Colors::Xterm256.new(100)

p c100.to_rgb_components
(16..255).each do |cc|
  c100 = Colors::Xterm256.new(cc)
  vv = Colors::Xterm256.find_closest( *c100.to_rgb_components )
  pp vv
  raise "#{vv}" if cc != vv
end
  


