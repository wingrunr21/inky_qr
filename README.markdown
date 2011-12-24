# InkyQR #

This gem provides the ability to generate QR codes with Inky embedded in the middle.  The QR codes utilize 25% error correction.  This allows the codes to be reliably scanned while also allowing suitably long payloads.  The embedded Inky takes up just less than 1/9 of the total QR code's area.

## Installation ##

Add the following to your Gemfile:

    gem 'inky_qr', :git => 'git@github.com:wingrunr21/inky_qr.git'

## Usage ##

A basic example:

    code = InkyQR::QRCode.new("http://www.customink.com")
    code.save("cink.svg")

You can also specify options:

    code = InkyQR::QRCode.new("http://www.customink.com", :color => "#F37321", :size => 600, :border => 15)
    code.save("cink2.svg")

Instead of saving the code to the file system you can have the raw file data returned:

    code = InkyQR::QRCode.new("http://www.customink.com")
    code.file_data # => returns a string representation of an XML document

Different file types can be specified in `save` or `file_data`:

    code = InkyQR::QRCode.new("http://www.customink.com")
    code.save("inky.png", :type => :png)
    code.file_data(:type => :jpeg)

QRCodes can be colorized and resized as needed:

    code = InkyQR::QRCode.new("http://www.customink.com")
    code2 = code.resize(800)
    code3 = code.colorize("#ababab")
    code.resize!(400)
    code.colorize!("#F37321")

### Options ###
* `color` - Specified in hex including the #.  Default is #000000
* `size` - Specified in pixels.  This is the target size, however, the code will shrink the total size so that the number of columns is even across the QR code. Default is 500
* `border` - Specified in pixels.  This is padding around the QR code.  Default is 0

## TODO ##
* Checks of some kind on input (color codes for example)
