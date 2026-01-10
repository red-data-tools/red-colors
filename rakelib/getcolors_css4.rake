require "open-uri"
require "nokogiri"

module GetColors
  CSS4_URI = "https://drafts.csswg.org/css-color-4/#named-colors"

  class CSS4
    def initialize
      @colordata = []
    end
    
    def get_data
      #html = File.read("index.html")
      html = URI.parse(CSS4_URI).read
      doc = Nokogiri::HTML(html)
      table = doc.css("table.named-color-table").first
      table.css("tbody").children.each do |kid|
        colorname = kid.css("dfn").text.strip
        next if colorname == ""
        rgb =  kid.css("td")[2].text.strip.upcase
        @colordata << [colorname, rgb]
      end
    end
    
    def header(fh)
      fh.puts <<~CSS4HEADER
        module Colors
          module ColorData
            # https://drafts.csswg.org/css-color-4/#named-colors
      CSS4HEADER
    end

    def middle(fh)
      fh.puts "    CSS4_COLORS = {"
      @colordata.each do |name, rgb|
        fh.puts "      \"#{name}\" => -\"#{rgb}\","
      end
    end

    def footer(fh)
      fh.puts <<~CSS4FOOTER
            }.freeze
          end
        end
      CSS4FOOTER
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
