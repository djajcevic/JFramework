Pod::Spec.new do |s|
  s.name                  = "JFramework"
  s.version               = "0.0.1"
  s.summary               = "Easier UIActivity inheritance."
  s.homepage              = "https://www.google.com"
  s.author                = { "Denis Jajčević" => "denis.jajcevic@gmail.com" }
  s.source                = { :git => "/Users/djajcevic/Documents/developer/jf/JFramework/.git", :tag => s.version.to_s }
  s.platform              = :ios
  s.ios.deployment_target = '6.0'
  s.source_files          = 'JFramework/**.{h,m}'
  s.requires_arc          = true
end
