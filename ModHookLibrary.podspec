#
# Be sure to run `pod lib lint ModHookLibrary.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ModHookLibrary'
  s.version          = '0.0.15'
  s.summary          = 'A APM of Launch initial hook.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 
  s.homepage         = 'https://github.com/bigParis/APM/blob/main/README.md'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'bigparis' => '1006599994@qq.com' }
  s.source           = { :git => 'https://github.com/bigParis/APM.git', :tag => s.version.to_s }
  s.cocoapods_version = '>= 1.09'
  s.screenshots = ['http://downhdlogo.yy.com/hdlogo/6060/60/60/32/2461322170/u2461322170obTmgQ4.png',
                     'http://lxcode.bs2cdn.yy.com/b4f15e01-f0fd-4ef7-a6b2-2283af482f4b.png', 
                     'http://lxcode.bs2cdn.yy.com/0b153d83-ef97-4529-8860-aa1f03595d89.png']
  # s.prepare_command = <<-CMD
  #       open "`pwd`"
  #    CMD
  # s.deprecated = true
  # s.deprecated_in_favor_of = 'ModHookLibraryOldName'
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

#  s.source_files = 'ModHookLibrary/Classes/**/*'
  
  # s.resource_bundles = {
  #   'ModHookLibrary' => ['ModHookLibrary/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '3.2.1', :configurations => ['Debug']
  # s.info_plist = {
  # 'CFBundleIdentifier' => 'com.myorg.MyLib',
  # }
  # s.pod_target_xcconfig = {'GCC_WARN_ABOUT_RETURN_TYPE' => 'NO'}
  s.module_name = 'APM01'

  s.subspec "APM1" do |spec|
    spec.source_files   ="ModHookLibrary/Classes/APM1/**/*"
    spec.public_header_files ="ModHookLibrary/Classes/APM1/*.{h}"
#    spec.header_mappings_dir = "APM1"
    spec.header_dir ="APM1"
  end

  s.subspec "APM2" do |spec|
    spec.source_files   ="ModHookLibrary/Classes/APM2/**/*"
    spec.public_header_files ="ModHookLibrary/Classes/APM2/BPTestCode2.h"
#    spec.private_header_files ="ModHookLibrary/Classes/APM2/BPTestCode2Private.h"
#    spec.header_mappings_dir = "APM2"
    spec.header_dir ="APM2"
    spec.dependency"ModHookLibrary/APM1"
  end

  s.subspec "APM3" do |spec|
    spec.source_files   ="ModHookLibrary/Classes/APM3/**/*"
    spec.public_header_files ="ModHookLibrary/Classes/APM3/*.{h}"
#    spec.header_mappings_dir = "APM3"
    spec.header_dir ="APM3"
    spec.dependency"ModHookLibrary/APM1"
  end
end
