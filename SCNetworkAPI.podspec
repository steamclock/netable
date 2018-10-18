Pod::Spec.new do |s|
  s.name         = "SCNetworkAPI"
  s.version      = "0.0.1"
  s.summary      = "Steamclock internal networking API."
  s.homepage     = "https://github.com/steamclock/networkAPI"
  s.license      = "MIT" 
  s.author             = { "Brendan Lensink" => "brendan@steamclock.com", "Nigel Brooke" => "nigel@steamclock.com" }
  s.dependency 'Alamofire'
  s.ios.deployment_target = "10.0"
  s.osx.deployment_target = "10.12"
  s.source       = { :git => "https://github.com/steamclock/networkAPI.git", :tag => "#{s.version}" }
  s.source_files  = "SCNetworkAPI/SCNetworkAPI/Source/**/*.swift"
  s.exclude_files = "Classes/Exclude"
  s.swift_version = "4.2"
end
