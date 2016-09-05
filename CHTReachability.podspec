Pod::Spec.new do |s|
  s.name         = "CHTReachability"
  s.version      = "1.0.0"
  s.summary      = "A real network reachability library for iOS."
  s.homepage     = "https://github.com/chiahsien/CHTReachability"
  s.license      = "MIT"
  s.authors      = { "Nelson Tai" => "chiahsien@gmail.com" }
  s.source       = { :git => "https://github.com/chiahsien/CHTReachability.git", :tag => "#{s.version}" }
  s.requires_arc = true
  s.platform     = :ios, "8.0"

  s.framework = "SystemConfiguration"
  s.source_files = "CHTReachability.{h,m}", "Vender/**/*.{h,m}"
  s.public_header_files = "CHTReachability.h"

end
