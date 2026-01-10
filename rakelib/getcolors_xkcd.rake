require "open-uri"

module GetColors
  class XKCD
    XKCD_URI = "https://xkcd.com/color/rgb.txt"

    def initialize
      @comments = [] # list of commented strings
      @colordata = [] # list of name/color pairs
    end

    def get_data
      webdata = URI.parse(XKCD_URI).read
      webdata.each_line.map do |rawline|
        line = rawline.chomp.strip
        if /^#/.match?(line)
          @comments << line
        else
          tokens = line.split("\t")
          if tokens.length != 2
            raise "Expecting two tokens, but got #{tokens.inspect}"
          end
          @colordata << tokens
        end
      end
    end

    def header(fh)
      fh.puts <<~XKCDHEADER
        module Colors
          module ColorData
            # This mapping of color names -> hex values is taken from
            # a survey run by Randall Munroe see:
            # https://blog.xkcd.com/2010/05/03/color-survey-results/
            # for more details.  The results are hosted at
            # https://xkcd.com/color/rgb
            # and also available as a text file at
            # https://xkcd.com/color/rgb.txt
            #
      XKCDHEADER
    end

    def middle(fh)
      @comments.each do |line|
        fh.puts "    " + line
      end
      fh.puts "    XKCD_COLORS = {"
      @colordata.each do |name, rgb|
        fh.puts "      \"xkcd:#{name}\" => -\"#{rgb}\","
      end
    end

    def footer(fh)
      fh.puts <<~XKCDFOOTER
            }.freeze
          end
        end
      XKCDFOOTER
    end

    def dump_file(filename)
      File.open(filename, "w") do |fh|
        header(fh)
        middle(fh)
        footer(fh)
      end
    end
  end
end
