//
//  JGPBPhotoView.h
//  JGPhotoBrowser
//
//  Created by Mei Jigao on 2018/6/11.
//  Copyright © 2018年 MeiJigao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class JGPBPhoto;
@class JGPBPhotoView;

@protocol JGPBPhotoViewDelegate <NSObject>

@required
- (void)photoViewImageFinishLoad:(JGPBPhotoView *)photoView;
- (void)photoViewSingleTap:(JGPBPhotoView *)photoView;

@end

@interface JGPBPhotoView : UIScrollView

// 图片
@property (nonatomic, strong) JGPBPhoto *photo;

// 代理
@property (nonatomic, weak) id<JGPBPhotoViewDelegate> photoViewDelegate;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
