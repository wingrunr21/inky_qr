module InkyQr
  class QrCode < RQRCode::QrCode
    IMAGE_DIR = File.expand_path(File.join(__FILE__, '../../..', 'images'))

    def initialize(string, *args)
      # Hash that will lazy-load the inky images
      @inkys = {}

      # Call super
      super(string, *args)

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
        png = @png.resize(75, 75).replace(@inkys[size], 25, 25)
      when :small
        png = @png.resize(150, 150).replace(@inkys[size], 50, 50)
      when :medium
        png = @png.resize(300, 300).replace(@inkys[size], 100, 100)
      when :large
        png = @png.resize(450, 450).replace(@inkys[size], 150, 150)
      when :xlarge
        png = @png.resize(600, 600).replace(@inkys[size], 200, 200)
      end

      # Save inky
      png.save(File.join(path, name))
    end
  end
end
