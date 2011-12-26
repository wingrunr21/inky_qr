require 'rqrcode'
require 'googl'
require 'nokogiri'
require 'RMagick'

module InkyQR
  class QRCode < RQRCode::QRCode
    # Require all renderers
    Dir[File.join(File.dirname(__FILE__), 'renderers', '*.rb')].each do |file|
      require file
    end

    attr_reader :size, :color, :bg_color, :border, :svg

    # Size and color are used here, everything else is passed up the line
    DEFAULT_OPTIONS = {:size => 500, :color => "#000000", :bg_color => nil, :level => :q, :border => 0}

    RASTOR_TYPES = [:png, :gif, :jpg, :jpeg]

    def initialize(string, options = {})
      options = DEFAULT_OPTIONS.merge(options)

      @size = options[:size]
      @color = options[:color]
      @border = options[:border]
      @bg_color = options[:bg_color]

      # Attempt QR Code construction, if string is too long shorten it with goo.gl
      begin
        super(string, :size => 6, :level => options[:level])
      rescue
        super(Googl.shorten(string), :size => 6, :level => options[:level])
      end

      # Render the SVG
      @svg = Renderers::SVG.new(self)
    end

    # Resizes and returns a new QRCode
    def resize(size, border = 0)
      InkyQR::QRCode.new(@data, :size => size)
    end

    # Resizes destructively
    def resize!(size, border = 0)
      @size = size
      @svg = Renderers::SVG.new(self)
      self
    end

    # Colorizes and returns a new QRCode
    def colorize(color)
      InkyQR::QRCode.new(@data, :color => color)
    end

    # Colorizes destructively
    def colorize!(color)
      @color = color
      @svg = Renderers::SVG.new(self)
      self
    end

    # Returns the raw file data for this QRCode
    # The default file type is SVG (image/svg+xml)

    def file_data(type = :svg)
      if RASTOR_TYPES.include? type
        rastor = Renderers::Raster.new(self)
        rastor.data(type)
      else
        @svg.to_xml
      end
    end

    # Saves the QRCode to the given file
    # The default file saved is an SVG file
    def save(filename, type = :svg)
      File.open(filename, 'w') do |f|
        f.write(file_data(type))
      end
    end
  end
end
