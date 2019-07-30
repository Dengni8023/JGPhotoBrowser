#source 'https://github.com/cocoaPods/specs.git'
#source 'https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git'

# 源码测试请屏蔽此选项，否则源码库内部调用出现的警告将不会提示
#inhibit_all_warnings!
# iOS 8使用动态framework
use_frameworks!

# workspace
workspace "JGPhotoBrowser"

# platform
platform :ios, '9.0'

# JGNetworkReachabilityDemo
target "JGPhotoBrowserDemo" do
    
    # Local
    pod 'JGPhotoBrowser', :path => "."
    
    # project
    project "JGPhotoBrowserDemo/JGPhotoBrowserDemo.xcodeproj"
end

# 设置Pods最低版本
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 9.0
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
      end
    end
  end
end
