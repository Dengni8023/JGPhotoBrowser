//
//  JGPhotoLoadingView.h
//
//  Created by mj on 13-3-4.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kMinProgress 0.0001

@class JGPhotoBrowser;
@class JGPhoto;

@interface JGPhotoLoadingView : UIView
@property (nonatomic) float progress;

- (void)showLoading;
- (void)showFailure;
@end
