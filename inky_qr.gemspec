# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "inky_qr/version"

Gem::Specification.new do |s|
  s.name        = "inky_qr"
  s.version     = InkyQr::VERSION
  s.authors     = ["Stafford Brunk"]
  s.email       = ["sbrunk@customink.com"]
  s.homepage    = "https://github.com/wingrunr21/inky_qr"
  s.summary     = %q{This gem will create QR codes with Inky embedded in the middle}
  s.description = %q{This gem creates QR codes with Inky embedded in the middle.  Inky is set to take up 1/9 of the total area of the QR code}

  s.rubyforge_project = "inky_qr"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "googl", "~> 0.5.0"
  s.add_dependency "rqrcode", "~> 0.4.2"
  s.add_dependency "nokogiri", "~> 1.5.0"
  s.add_dependency "rubikon", "~> 0.6.0"
  s.add_dependency "rmagick", "~> 2.13.1"
end
