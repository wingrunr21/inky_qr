module InkyQR
  module Renderers
    class Raster
      def initialize(qr_code)
        @code = qr_code
      end

      def data(type = :png)
        # Convert from SVG every time to maintain quality
        @img = Magick::Image::from_blob(@code.svg.to_xml).first

        # Set the proper image type, default to png
        case type
        when :jpeg
          @img.format = "jpeg"
        when :jpg
          @img.format = "jpeg"
        when :gif
          @img.format = "gif"
        else
          @img.format = "png"
        end

        @img.to_blob
      end
    end
  end
end
