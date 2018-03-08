Pod::Spec.new do |s|
  s.name         = "ZWSHybridKit"
  s.version      = "0.1"
  s.summary      = "Hybird容器：App重点关注Native宿主容器部分，一是Webview控件使用封装：提供JSBridge交互桥接、账号信息互通设计、转场导航设计等；二是底层预加载与缓存机制等。"

  s.homepage     = "https://github.com/zhaowensky/ZWSHybridKit.git"
  s.license      = { :type => "MIT", :file => "ZWSHybridKit/LICENSE" }
  s.author       = { "zhaowensky" => "zhaowensky@gmail.com" }
 
  s.platform     = :ios, '8.0'
  s.source       = { :git => "https://github.com/zhaowensky/ZWSHybridKit.git", :tag => s.version.to_s }

  s.source_files  = "ZWSHybridKit/Class/*.{h,m}"

  s.requires_arc = true

end
