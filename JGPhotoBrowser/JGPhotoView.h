//
//  JGPhotoView.h
//  JGPhotoBrowserExample
//
//  Created by 梅继高 on 2017/6/29.
//  Copyright © 2017年 Jigao Mei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JGPhoto.h"

@class JGPhotoView;

@protocol JGPhotoViewDelegate <NSObject>

- (void)photoViewImageFinishLoad:(JGPhotoView *)photoView;
- (void)photoViewSingleTap:(JGPhotoView *)photoView;

@end

@interface JGPhotoView : UIScrollView

// 图片
@property (nonatomic, strong) JGPhoto *photo;
// 代理
@property (nonatomic, weak) id<JGPhotoViewDelegate> photoViewDelegate;

@end
