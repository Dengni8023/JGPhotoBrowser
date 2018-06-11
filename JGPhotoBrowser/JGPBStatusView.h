//
//  JGPBStatusView.h
//  JGPhotoBrowser
//
//  Created by Mei Jigao on 2018/6/11.
//  Copyright © 2018年 MeiJigao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define JGPhotoLoadMinProgress 0.0001

typedef NS_ENUM(NSInteger, JGPBPhotoStatus) {
    JGPBPhotoStatusNone = 0,
    JGPBPhotoStatusLoading = 1,
    JGPBPhotoStatusLoadFail,
    JGPBPhotoStatusSaveSuccess,
    JGPBPhotoStatusSaveFail,
    JGPBPhotoStatusPrivacy,
    
    JGPBPhotoStatusDefault = JGPBPhotoStatusNone,
};

@interface JGPBStatusView : UIView

@property (nonatomic, assign) CGFloat progress;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

- (void)showWithStatus:(JGPBPhotoStatus)status;

@end

NS_ASSUME_NONNULL_END
