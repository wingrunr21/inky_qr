# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "inky_qr/version"

Gem::Specification.new do |s|
  s.name        = "inky_qr"
  s.version     = InkyQr::VERSION
  s.authors     = ["Stafford Brunk"]
  s.email       = ["wingrunr21@gmail.com"]
  s.homepage    = "http://www.customink.com"
  s.summary     = %q{This gem will create QR codes with Inky embedded in the middle}
  s.description = %q{This gem creates QR codes with Inky embedded in the middle.  Inky is set to take up 1/9 of the total area of the QR code}

  s.rubyforge_project = "inky_qr"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "googl", "~> 0.5.0"
  s.add_dependency "rqrcode_png", "~> 0.1.1"
  s.add_dependency "oily_png", "~> 1.0.2"
  s.add_dependency "rubikon", "~> 0.6.0"

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
