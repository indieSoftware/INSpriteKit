Pod::Spec.new do |s|
  s.name             = "INSpriteKit"
  s.version          = "0.1.0"
  s.summary          = "Some SpriteKit extensions used by indie-Software."
  s.homepage         = "https://github.com/indieSoftware/INSpriteKit"
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = "Sven Korset"

  s.platform         = :ios
  s.ios.deployment_target = '7.0'
  s.requires_arc     = true
  
  s.frameworks       = 'SpriteKit', 'GLKit'
  
  s.source           = { :git => "https://github.com/indieSoftware/INSpriteKit.git", :tag => "0.1.0" }
  s.source_files     = 'INSpriteKit/**/*.{h,m}'

end
