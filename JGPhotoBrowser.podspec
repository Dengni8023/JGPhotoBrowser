
Pod::Spec.new do |s|
    
    s.name          = "JGPhotoBrowser"
    s.version       = "2.0.0"
    
    s.summary       = "图片大图浏览查看工具，支持GIF图片。改写自 Sunnyyoung/MJPhotoBrowser (https://github.com/Sunnyyoung/MJPhotoBrowser)"
    s.description   = <<-DESC
    
        图片大图浏览查看工具，支持GIF图片。改写自 Sunnyyoung/MJPhotoBrowser (https://github.com/Sunnyyoung/MJPhotoBrowser)
        
        功能包括：
            1、浏览图片大图，支持手势缩放
            2、支持图片保存、支持GIF图片保存
            3、增加图片介绍展示
    DESC
    
    s.homepage      = "https://github.com/dengni8023/JGPhotoBrowser"
    s.license       = {
        :type => 'MIT',
        :file => 'LICENSE',
    }
    s.author        = {
        "等你8023" => "945835664@qq.com",
    },
    
    s.source        = {
        :git => "https://github.com/dengni8023/JGPhotoBrowser.git",
        :tag => "#{s.version}",
    }
    s.platforms     = {
        :ios => 9.0,
    }
    
    s.source_files  = "JGPhotoBrowser/*.{h,m}"
    s.public_header_files  = "JGPhotoBrowser/{JGPhotoBrowser,JGSPhotoBrowser,JGSPhoto}.h"
    # s.resource    = "JGAlertController/JGAlertController.bundle"
    
    # s.framework  = "Photos"
    # s.frameworks = "SomeFramework", "AnotherFramework"
    
    # s.library   = "objc"
    # s.libraries = "iconv", "xml2"
    
    s.requires_arc = true
    
    s.dependency "SDWebImage", "~> 4.4.6"
    s.dependency "SDWebImage/GIF"
    s.dependency "JGSourceBase", "~> 1.0.0"
    
end
