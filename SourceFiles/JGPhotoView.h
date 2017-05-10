//
//  MJZoomingScrollView.h
//
//  Created by mj on 13-3-4.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JGPhotoBrowser, JGPhoto, JGPhotoView;

@protocol JGPhotoViewDelegate <NSObject>
- (void)photoViewImageFinishLoad:(JGPhotoView *)photoView;
- (void)photoViewSingleTap:(JGPhotoView *)photoView;
@end

@interface JGPhotoView : UIScrollView <UIScrollViewDelegate>
// 图片
@property (nonatomic, strong) JGPhoto *photo;
// 代理
@property (nonatomic, strong) id<JGPhotoViewDelegate> photoViewDelegate;

@end
