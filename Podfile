source 'https://github.com/CocoaPods/Specs.git'

# 源码测试请屏蔽此选项，否则源码库内部调用出现的警告将不会提示
#inhibit_all_warnings!
# iOS 8使用动态framework
use_frameworks!

# workspace
workspace "JGPhotoBrowser"

# platform
platform :ios, '8.0'

# JGNetworkReachabilityDemo
target "JGPhotoBrowserDemo" do
    
    # Local
    pod 'JGPhotoBrowser', :path => "."
    
    # project
    project "JGPhotoBrowserDemo/JGPhotoBrowserDemo.xcodeproj"
end
