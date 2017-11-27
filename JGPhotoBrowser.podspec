
Pod::Spec.new do |s|

s.name          = "JGPhotoBrowser"
s.version       = "1.2.3"

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
    :ios => 8.0,
}
s.source_files  = "JGPhotoBrowser/*.{h,m}"
# s.resource    = "JGAlertController/JGAlertController.bundle"

# s.framework  = "SomeFramework"
# s.frameworks = "SomeFramework", "AnotherFramework"

# s.library   = "iconv"
# s.libraries = "iconv", "xml2"

s.dependency "SDWebImage", "~> 4.2.2"
s.dependency "SDWebImage/GIF"

s.dependency "JGSourceBase", "~> 0.0.2"

s.requires_arc = true

end
