//
//  JGSPhotoView.h
//  JGSPhotoBrowser
//
//  Created by 梅继高 on 2019/3/28.
//  Copyright © 2019 MeiJigao. All rights reserved.
//

#import <UIKit/UIKit.h>
#if __has_include(<JGSPhotoBrowser/JGSPhotoBrowser.h>)
#import <JGSPhotoBrowser/JGSPhoto.h>
#else
#import "JGSPhoto.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@class JGSPhotoView;
@protocol JGSPhotoViewDelegate <NSObject>

@required
- (void)photoViewImageFinishLoad:(JGSPhotoView *)photoView;
- (void)photoViewSingleTap:(JGSPhotoView *)photoView;

@end

@interface JGSPhotoView : UIScrollView

@property (nonatomic, strong) JGSPhoto *photo; // 图片
@property (nonatomic, weak) id<JGSPhotoViewDelegate> photoViewDelegate; // 代理

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
