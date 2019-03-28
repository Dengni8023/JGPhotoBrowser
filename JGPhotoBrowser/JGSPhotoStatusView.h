//
//  JGSPhotoStatusView.h
//  JGSPhotoBrowser
//
//  Created by 梅继高 on 2019/3/28.
//  Copyright © 2019 MeiJigao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define JGSPhotoLoadMinProgress 0.0001 // 图片加载展示的最小进度
typedef NS_ENUM(NSInteger, JGSPhotoStatus) {
    JGSPhotoStatusNone = 0,
    JGSPhotoStatusLoading = 1,
    JGSPhotoStatusLoadFail,
    JGSPhotoStatusSaveSuccess,
    JGSPhotoStatusSaveFail,
    JGSPhotoStatusPrivacy,
};

@interface JGSPhotoStatusView : UIView

@property (nonatomic, assign) CGFloat progress;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

- (void)showWithStatus:(JGSPhotoStatus)status;

@end

@interface JGSPhotoProgressView : UIView

@property (nonatomic, strong, null_resettable) UIColor *trackTintColor;
@property (nonatomic, strong, null_resettable) UIColor *progressTintColor;
@property (nonatomic, assign) CGFloat progress;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
