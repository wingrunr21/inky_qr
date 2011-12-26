module InkyQR
  module Renderers
    class SVG
      # Dir should contain the inky SVG file
      INKY_FILE = File.expand_path(File.join(__FILE__, '../../../..', 'resources', 'inky.svg'))

      # Map background width to minimize it behind inky
      INKY_BG_MAP = [9,11,13,15,15,15,15,15,15,15,13,13,13,11,5]

      def initialize(qr_code)
        @code = qr_code

        # Load inky
        @inky ||= Nokogiri::XML(File.read(INKY_FILE))

        render!
      end

      def to_xml
        render! if @doc.nil?
        @doc.to_xml
      end

      private
      def render!
        # calculate size after border
        adj_size = @code.size - (@code.border * 2)

        # how big is each column?
        col_width = (adj_size / @code.module_count.to_f).round

        # Recalculate the adjusted size so column numbers are even
        adj_size = (col_width * @code.module_count) + (2 * @code.border)

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
        @code.modules.each_index do |r|
          @code.modules.each_index do |c|
            y = r * col_width + @code.border
            x = c * col_width + @code.border

            # Fill with bg_color unless this segment is dark
            fill = @code.bg_color
            if @code.dark?(r, c)
              fill = @code.color
            end

            # Build and add the rect
            unless fill.nil?
              rect = build_rect(x, y, col_width, col_width, fill, @doc)
              qr_code << rect
            end
          end
        end

        # Figure out how many columns is 1/3 of the width
        bg_width = @code.module_count / 3
        bg_width += @code.module_count % 3 # extra gets added to the total inky width

        # Calculate offset from side of image
        offset = (@code.module_count - bg_width) / 2
        offset *= col_width
        offset += @code.border

        # Remove foreground tiles for inky background
        bg_width.times do |i|
          # Internal offset to center row
          bg_offset = (bg_width - INKY_BG_MAP[i]) / 2

          y = i * col_width + offset

          # Cycle over all "touched" tiles and delete the foreground color ones
          INKY_BG_MAP[i].times do |j|
            # Make rows as wide as specified in the map
            x = ((bg_offset + j) * col_width) + offset

            # Find proper rectangle
            node = @doc.at_css("g#qr_code rect[x='#{x}'][y='#{y}'][fill='#{@code.color}']")
            unless node.nil?
              # If our bg is transparent, delete the node, otherwise modify fill color
              if @code.bg_color.nil?
                node.remove
              else
                node["fill"] = @code.bg_color
              end
            end
          end
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
          path["fill"] = @code.color

          inky << path
        end

        # Add inky
        svg << inky
      end

      # Helper method to build a SVG rectangle
      # Returns a Nokogiri XML node
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
end
