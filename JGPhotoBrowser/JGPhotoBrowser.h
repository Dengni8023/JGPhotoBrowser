//
//  JGPhotoBrowser.h
//  JGPhotoBrowser
//
//  Created by 梅继高 on 2019/7/29.
//  Copyright © 2019 MeiJigao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Availability.h>

// 最低版本限制处理
#if __ENVIRONMENT_IPHONE_OS_VERSION_MIN_REQUIRED__ < __IPHONE_9_0
#error "JGSourceBase uses features only available in iOS SDK 9.0 and later."
#endif

//! Project version number for JGPhotoBrowser.
FOUNDATION_EXPORT double JGPhotoBrowserVersionNumber;

//! Project version string for JGPhotoBrowser.
FOUNDATION_EXPORT const unsigned char JGPhotoBrowserVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <JGPhotoBrowser/PublicHeader.h>

// JGS 缩写说明
// JG: 作者
// S: SourceCode

#if __has_include(<JGSPhotoBrowser/JGPhotoBrowser.h>)
#import <JGPhotoBrowser/JGSPhotoBrowser.h>
#else
#import "JGSPhotoBrowser.h"
#endif
