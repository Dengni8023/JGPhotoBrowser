source 'https://github.com/CocoaPods/Specs.git'

inhibit_all_warnings!
# iOS 8使用动态framework
use_frameworks!

# workspace
workspace "JGPhotoBrowser"

# platform
platform :ios, '8.0'

# JGPhotoBrowser
target "JGPhotoBrowser" do
    
    # JGSourceBase
    pod 'JGSourceBase', "~> 0.0.1"
    
    # Asynchronous image downloader with cache support with an UIImageView category
    pod 'SDWebImage', '~> 4.2.2' # https://github.com/rs/SDWebImage
    pod 'SDWebImage/GIF' # GIF image，use FLAnimatedImageView instead of UIImageView
    
    # project
    project "JGPhotoBrowser.xcodeproj"
    
end

# Demo中必须保留，即使内部无任何Pod依赖，否则Demo中无法使用JGAlertController依赖的Pod库
# JGNetworkReachabilityDemo
target "JGPhotoBrowserDemo" do
    
    # project
    project "JGPhotoBrowser.xcodeproj"
end
