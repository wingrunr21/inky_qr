require 'rqrcode_png'

module InkyQR
  class QRCode < RQRCode::QRCode
    IMAGE_DIR = File.expand_path(File.join(__FILE__, '../../..', 'images'))

    def initialize(string)
      # Hash that will lazy-load the inky images
      @inkys = {}

      # Call super
      super(string, :size => 6)

      # Convert self to image
      @png = self.to_img
    end

    def save(name = "", *args)
      options = args.extract_options!

      # Extract options
      size = options[:size] || :medium
      name ||= "inkyqr_#{size.to_s}.png"
      path = options[:path] || "."

      # Lazy load inky
      @inkys[size] ||= ChunkyPNG::Image.from_file(File.join(IMAGE_DIR, "inky_#{size.to_s}.png"))

      # Resize png based on input size
      case size
      when :tiny
        png = @png.resize(75, 75).compose(@inkys[size], 25, 25)
      when :small
        png = @png.resize(150, 150).compose(@inkys[size], 49, 49)
      when :medium
        png = @png.resize(300, 300).compose(@inkys[size], 98, 98)
      when :large
        png = @png.resize(450, 450).compose(@inkys[size], 147, 147)
      when :xlarge
        png = @png.resize(600, 600).compose(@inkys[size], 196, 196)
      end

      # Save inky
      png.save(File.join(path, name))
    end
  end
end
