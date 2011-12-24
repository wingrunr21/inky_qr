require 'rqrcode'
require 'googl'
require 'nokogiri'

module InkyQR
  class QRCode < RQRCode::QRCode
    attr_reader :size, :color

    # Dir should contain the inky SVG file
    INKY_FILE = File.expand_path(File.join(__FILE__, '../../..', 'resources', 'inky.svg'))

    # Size and color are used here, everything else is passed up the line
    DEFAULT_OPTIONS = {:size => 500, :color => "#000000", :level => :q, :border => 0}

    # Map background width to minimize it behind inky
    INKY_BG_MAP = [9,11,13,15,15,15,15,15,15,15,13,13,13,11,5]

    def initialize(string, options = {})
      options = DEFAULT_OPTIONS.merge(options)

      @size = options[:size]
      @color = options[:color]
      @border = options[:border]

      # Attempt QR Code construction, if string is too long shorten it with goo.gl
      begin
        super(string, :size => 6, :level => options[:level])
      rescue
        super(Googl.shorten(string), :size => 6, :level => options[:level])
      end

      # Load inky
      @inky ||= Nokogiri::XML(File.read(INKY_FILE))

      # build the SVG
      build_svg
    end

    # Builds the SVG document with Nokogiri
    def build_svg
      # calculate size after border
      adj_size = @size - (@border * 2)

      # how big is each column?
      col_width = (adj_size / @module_count.to_f).round

      # Recalculate the adjusted size so column numbers are even
      adj_size = (col_width * @module_count) + (2 * @border)

      # Begin XML doc construction
      @doc = Nokogiri::XML::Document.new
      @doc.encoding = "utf-8"

      # Create the svg node and make it adj_size by adj_size
      svg = Nokogiri::XML::Node.new "svg", @doc
      svg["height"] = adj_size.to_s
      svg["width"] = adj_size.to_s
      svg["version"] = "1.1"
      svg["xmlns"] = "http://www.w3.org/2000/svg"
      @doc << svg

      # Create the qr_code group
      qr_code = Nokogiri::XML::Node.new "g", @doc
      qr_code["id"] = "qr_code"
      svg << qr_code

      # Build the QR code
      @modules.each_index do |r|
        @modules.each_index do |c|
          y = r * col_width + @border
          x = c * col_width + @border

          # Fill with white unless this segment is dark
          fill = "#ffffff"
          if self.dark?(r, c)
            fill = @color
          end

          # Build and add the rect
          rect = build_rect(x, y, col_width, col_width, fill, @doc)
          qr_code << rect
        end
      end

      # Figure out how many columns is 1/3 of the width
      bg_width = @module_count / 3
      bg_width += @module_count % 3 # extra gets added to the total inky width

      # Calculate offset from side of image
      offset = (@module_count - bg_width) / 2
      offset *= col_width
      offset += @border

      # Add background group
      background = Nokogiri::XML::Node.new "g", @doc
      background["id"] = "background"
      svg << background

      # Construct background
      bg_width.times do |i|
        # Internal offset to center row
        bg_offset = (bg_width - INKY_BG_MAP[i]) / 2

        # Make rows as wide as specified in the map
        y = i * col_width + offset
        x = bg_offset * col_width + offset

        # Build and add rect
        rect = build_rect(x, y, col_width, col_width * INKY_BG_MAP[i], "#ffffff", @doc)
        background << rect
      end

      # Calculate actual background width in pixels
      bg_width_px = bg_width * col_width

      # Calculate inky offsets
      inky_svg = @inky.at_css("svg")
      i_width = inky_svg["width"].to_f
      i_height = inky_svg["height"].to_f

      # We need to scale inky up to the bg width
      # subtract 2 to give a small border around inky
      scale_factor = ( bg_width_px - 2 ) / i_width

      # Compensate for offsets
      h_offset = ((bg_width_px - (i_height * scale_factor)) / 2).round + offset
      w_offset = ((bg_width_px - (i_width * scale_factor)) / 2).round + offset

      # Grab inky data
      inky = Nokogiri::XML::Node.new "g", @doc
      inky["id"] = "inky"
      inky["transform"] = "translate(#{w_offset}, #{h_offset}) scale(#{scale_factor})"

      # Colorize inky
      @inky.css("path").each do |path|
        path["fill"] = @color

        inky << path
      end

      # Add inky
      svg << inky
    end

    def resize(size, border = 0)
      InkyQR::QRCode.new(@data, :size => size)
    end

    def resize!(size, border = 0)
      @size = size
      build_svg
      self
    end

    def colorize(color)
      InkyQR::QRCode.new(@data, :color => color)
    end

    def colorize!(color)
      @color = color
      build_svg
      self
    end

    def file_data(type = :svg)
      @doc.to_xml
    end

    def save(filename, type = :svg)
      File.open(filename, 'w') do |f|
        f.write(@doc.to_xml)
      end
    end

    private
    def build_rect(x, y, height, width, fill, doc)
      rect = Nokogiri::XML::Node.new "rect", doc
      rect["x"] = x.to_s
      rect["y"] = y.to_s
      rect["height"] = height.to_s
      rect["width"] = width.to_s
      rect["fill"] = fill
      rect
    end
  end
end
