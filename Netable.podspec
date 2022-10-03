 Pod::Spec.new do |s|
  s.name             = 'Netable'
  s.version          = '2.0.0'
  s.summary          = 'A simple and swifty networking library.'
  s.description      = 'Netable is a simple Swift framework for working with both simple and non-REST-compliant HTTP endpoints.'
  s.homepage         = 'https://github.com/steamclock/netable/'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Brendan Lensink' => 'brendan@steamclock.com' }
  s.source           = { :git => 'https://github.com/steamclock/netable.git', :tag => 'v2.0.0' }
  s.ios.deployment_target = '15.0'
  s.osx.deployment_target  = '10.14'
  s.source_files = 'Netable/Netable/*.{swift,h,m}'
  s.swift_version = '5.0'
  s.deprecated = true
  s.deprecated_in_favor_of = "Swift Package Manager"
end
