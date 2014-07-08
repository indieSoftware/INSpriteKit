Pod::Spec.new do |s|
  s.name             = "INSpriteKit"
  s.version          = "1.0.1"
  s.summary          = "A little iOS Library with SpriteKit extensions."
  s.homepage         = "https://github.com/indieSoftware/INSpriteKit"
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = "Sven Korset"

  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.9'
  s.requires_arc     = true
  
  s.frameworks       = 'SpriteKit', 'GLKit'
  
  s.source           = { :git => "https://github.com/indieSoftware/INSpriteKit.git", :tag => "1.0.1" }
  s.source_files     = 'INSpriteKit/**/*.{h,m}'

end
