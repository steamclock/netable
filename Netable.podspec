Pod::Spec.new do |s|
  s.name             = 'Netable'
  s.version          = '0.8.4'
  s.summary          = 'A simple and swifty networking library.'
  s.description      = 'Netable is a simple Swift framework for working with both simple and non-REST-compliant HTTP endpoints.'
  s.homepage         = 'https://github.com/steamclock/netable/'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Brendan Lensink' => 'brendan@steamclock.com' }
  s.source           = { :git => 'https://github.com/steamclock/netable.git', :tag => 'v0.8.4' }
  s.ios.deployment_target = '11.0'
  s.osx.deployment_target  = '10.14'
  s.source_files = 'Netable/Netable/*.{swift,h,m}'
end
