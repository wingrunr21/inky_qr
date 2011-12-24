require 'rqrcode'
require 'googl'
require 'nokogiri'

module InkyQR
  class QRCode < RQRCode::QRCode
    attr_reader :size, :color, :border

    # Size and color are used here, everything else is passed up the line
    DEFAULT_OPTIONS = {:size => 500, :color => "#000000", :level => :q, :border => 0}

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

      # Render the SVG
      @svg = Renderers::SVG.new(self)
    end

    def resize(size, border = 0)
      InkyQR::QRCode.new(@data, :size => size)
    end

    def resize!(size, border = 0)
      @size = size
      @svg = Renderers::SVG.new(self)
      self
    end

    def colorize(color)
      InkyQR::QRCode.new(@data, :color => color)
    end

    def colorize!(color)
      @color = color
      @svg = Renderers::SVG.new(self)
      self
    end

    def file_data(type = :svg)
      @svg.to_xml
    end

    def save(filename, type = :svg)
      File.open(filename, 'w') do |f|
        f.write(@svg.to_xml)
      end
    end
  end
end
