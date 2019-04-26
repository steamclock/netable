Pod::Spec.new do |s|
  s.name             = 'SCNetworkAPI'
  s.version          = '0.1.0'
  s.summary          = 'Networking library.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC
  s.homepage         = 'https://github.com/steamclock/networkAPI/'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Brendan Lensink' => 'brendan@steamclock.com' }
  s.source           = { :git => 'https://github.com/steamclock/networkAPI.git', :tag => s.version.to_s }
  s.ios.deployment_target = '10.0'
  s.osx.deployment_target  = '10.12'
  s.source_files = 'SCNetworkAPI/Source/*.{swift,h,m}'
end
