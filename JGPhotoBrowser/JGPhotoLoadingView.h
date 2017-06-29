//
//  JGPhotoLoadingView.h
//  JGPhotoBrowserExample
//
//  Created by 梅继高 on 2017/6/29.
//  Copyright © 2017年 Jigao Mei. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kMinProgress 0.0001

@interface JGPhotoLoadingView : UIView

@property (nonatomic, assign) CGFloat progress;

- (void)showLoading;
- (void)showFailure;

@end
