require "rubygems"
require "bundler/gem_helper"

base_dir = File.join(File.dirname(__FILE__))

helper = Bundler::GemHelper.new(base_dir)
def helper.version_tag
  version
end

helper.install
spec = helper.gemspec

desc "Run tests"
task :test do
  ruby("test/run.rb")
end

task default: :test

task :get_xkcd do
  xkcd = GetColors::XKCD.new
  xkcd.get_data
  xkcd.dump_file("lib/colors/color_data/xkcd.rb")
end

task :get_css4 do
  css4 = GetColors::CSS4.new
  css4.get_data
  css4.dump_file("lib/colors/color_data/css4.rb")
end

desc "Get color data files from the web, per issue #8"
task :get_colors => [:get_xkcd, :get_css4]
