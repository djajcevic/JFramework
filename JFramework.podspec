Pod::Spec.new do |s|
  s.name         = 'JFramework'
  s.version      = '0.0.1'
  s.summary      = 'An Objective-C helper framework'
  s.homepage     = 'https://github.com/jfwork/JFramework'
  s.author       = 'Denis Jajčević'
  s.source       = { :git => 'https://github.com/jfwork/JFramework.git', :tag => s.version.to_s }
  s.source_files = 'JFramework/Classes/*.{h,m}'
  s.requires_arc = true
  s.framework = 'UIKit', 'AdSupport', 'CoreData', 'QuartzCore'
end