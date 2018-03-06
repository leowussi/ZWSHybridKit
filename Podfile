#coding = utf-8
source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!
platform :ios, '8.0'
inhibit_all_warnings!

pod 'WebViewJavascriptBridge', '~> 6.0.3'
pod 'NJKWebViewProgress', '~> 0.2.3'
pod 'AFNetworking', '~> 3.2.0'

target 'ZWSWebView' do
end

#Automatically manage signing
post_install do |installer| installer.pods_project.build_configurations.each do |config| config.build_settings['CODE_SIGN_STYLE'] = 'Automatic' end end




